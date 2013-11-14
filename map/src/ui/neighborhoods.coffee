'use strict'

define [
  'underscore'
  'flight/lib/component',
  'lib/fusiontip/fusiontip',
  'lib/accounting/accounting'
  'map/utils/mobile_detection'
], (
  _,
  defineComponent,
  fusionTip,
  accounting,
  mobileDetection
) ->

  class ToolTip extends google.maps.OverlayView
    constructor: (@map, @template, @data) ->
      @setMap(@map)

    container: $("<div/>",
      class: "hood-info-window"
    )
    position: null
    count: null

    destroy: ->
      @setMap(null)

    onAdd: ->
      @container.appendTo @getPanes().overlayLayer

    onRemove: ->
      @container.remove()

    draw: ->
      @position = new google.maps.LatLng @data.latitude, @data.longitude
      overlayProjection = @getProjection()
      px = overlayProjection.fromLatLngToDivPixel(@position)
      @container.css
        position: "absolute"
        "z-index": 999
        left: px.x
        top: px.y

    setContent: (data) ->
      console.log data
      @container.html(_.template(@template, data))



  neighborhoodsOverlay = ->

    @defaultAttrs
      enableOnboardCalls: false
      enableMouseover: false
      tableId: undefined
      apiKey: undefined
      hoodLayer: undefined
      gMap: undefined
      toggleLink: undefined
      toggleControl: undefined
      data: undefined
      infoTemplate: undefined
      tipStyle: ''
      mouseTipDelay: 200
      suppressMapTips: false
      minimalZommLevel: 12
      polygons: []
      wait: 500

      polyOptions:
        clicked:
          strokeColor: "#000"
          strokeOpacity: .5
          strokeWeight: 1
          fillColor: "#000"
          fillOpacity: .2

        mouseover:
          strokeColor: "#000"
          strokeOpacity: .5
          strokeWeight: 1
          fillColor: "#000"
          fillOpacity: .2

        mouseout:
          strokeWeight: 0
          fillOpacity: 0

      polygonOptions:
        fillColor: "BC8F8F"
        fillOpacity: 0.1
        strokeColor: "4D4D4D"
        strokeOpacity: 0.8
        strokeWeight: 1

      polygonOptionsCurrent:
        fillOpacity: 0.5
        strokeColor: '4D4D4D'
        strokeOpacity: 0.7,
        strokeWeight: 2

      infoWindowData:
        state: undefined
        hood: undefined
        population: undefined
        growth: undefined
        density: undefined
        males: undefined
        females: undefined
        median_income: undefined
        average_income: undefined

    @infoWindow = new google.maps.InfoWindow()


    @hoodQuery = (data) ->
      where = "WHERE LATITUDE >= #{data.lat1} AND LATITUDE <= #{data.lat2} AND LONGITUDE >= #{data.lng1} AND LONGITUDE <= #{data.lng2}"

      "SELECT geometry, HOOD_NAME, STATENAME, MARKET, LATITUDE, LONGITUDE FROM #{@attr.tableId} #{where}"


    @addHoodsLayer = (ev, data) ->
      return if !data or !data.gMap or data.gMap.getZoom() < @attr.minimalZommLevel

      @attr.gMap = data.gMap
      @attr.data = data
      @toolTip = new ToolTip(@attr.gMap, @attr.infoTemplate, @attr.data) unless @toolTip
      @getKmlData(data)

    @setupMouseOver = (event, data) ->
      if !@isMobile() && @attr.enableMouseover
        @buildInfoWindow(event, data)

    @getKmlData = (data) ->
      url = ["https://www.googleapis.com/fusiontables/v1/query?sql="]
      url.push encodeURIComponent(@hoodQuery(data))
      url.push "&key=#{@attr.apiKey}"

      $.ajax
        url: url.join("")
        dataType: "jsonp"
        success: (data) =>
          @buildPolygons(data)

    @clearPolygons = ->
      return unless @attr.polygons.length

      for x in @attr.polygons
        x.setMap(null) if x

      @attr.polygons = []
      return

    @buildPolygons = (data) ->
      rows = data.rows
      @clearPolygons()
      for row in rows
        continue unless rows[0]

        polygonData = @buildPaths(row)
        hoodData = @buildHoodData(row)

        @wireupPolygon(polygonData, hoodData)

    @wireupPolygon = (polygonData, hoodData) ->
      mouseOverOptions = @attr.polyOptions.mouseover
      mouseOutOptions = @attr.polyOptions.mouseout

      isCurrentHood = (@attr.data.hood == hoodData.hood)
      initialOptions = if isCurrentHood then mouseOverOptions else mouseOutOptions

      hoodLayer = new google.maps.Polygon(
        _.extend({paths:polygonData}, initialOptions)
      )


      google.maps.event.addListener hoodLayer, "mouseover", (e)->
        @setOptions(mouseOverOptions)
        $(document).trigger 'hoodMouseOver', { data: hoodData }

      unless isCurrentHood
        google.maps.event.addListener hoodLayer, "mouseout", ->
          @setOptions(mouseOutOptions)
          $(document).trigger 'closeInfoWindow'

      hoodLayer.setMap @attr.gMap
      @attr.polygons.push hoodLayer

      return

    @buildPaths = (row) ->
      coordinates = []
      if geometry = row[0].geometry
        if geometry.type == 'Polygon'
          coordinates = @makePathsCoordinates(geometry.coordinates[0])
      coordinates

    @isValidPoint = (arr) ->
      arr.length == 2 and _.all(arr, _.isNumber)

    @makePathsCoordinates = (coordinates) ->
      if this.isValidPoint(coordinates)
        new google.maps.LatLng(coordinates[1], coordinates[0])
      else
        _.map(coordinates, @makePathsCoordinates, this)

    @buildHoodData = (row) ->
      if typeof row[0] == 'object'
        _.object(['hood', 'state', 'city', 'lat', 'lng'], row.slice(1))
      else
        {}

    @buildToolTip = (ev, data) ->
      console.log "Tooltip Position", data.position

    @buildInfoWindow = (event, polygonData) ->
      return unless polygonData

      setTimeout =>
        @trigger document, 'uiNHoodInfoWindowDataRequest'

        infoData = @buildOnboardData(polygonData.data)
        location = new google.maps.LatLng(polygonData.data.lat, polygonData.data.lng)

        @infoWindow.setContent(_.template(@attr.infoTemplate, infoData))
        @infoWindow.setPosition(location)
        @infoWindow.open(@attr.gMap)
        @toolTip.setContent(infoData)
      , @attr.wait

    @buildOnboardData = (data) ->
      return unless @attr.enableOnboardCalls

      onboardData = JSON.parse(@getOnboardData(data).responseText)
      data = _.extend(@attr.infoWindowData, data)

      unless _.isEmpty(onboardData)
        demographic = onboardData.demographic
        for key, value of @attr.infoWindowData
          if demographic[key]
            data[key] = @formatValue(key, demographic[key])

      data

    @formatValue = (key, value) ->
      switch key
        when 'median_income', 'average_income'
          accounting.formatMoney(value)
        when 'population'
          accounting.formatNumber(value)
        else
          value

    @getOnboardData = (data) ->
      return {} if _.isEmpty(data)

      query = []
      query.push "state=#{@toDashes(data.state)}"
      query.push "city=#{@toDashes(data.city)}"
      query.push "neighborhood=#{@toDashes(data.hood)}"

      xhr = $.ajax
        url: "/meta/community?rectype=NH&#{query.join('&')}"
        async: false
      .done (data) ->
        data
      .fail (data) ->
        {}

    @hideInfoWindow = ->
      @infoWindow.close() if @infoWindow

    @toDashes = (value) ->
      return '' unless value?

      value.replace(' ', '-')

    @toSpaces = (value) ->
      return '' unless value?

      value.replace('-', ' ')

    @after 'initialize', ->
      @on document, 'uiNeighborhoodDataRequest', @addHoodsLayer
      @on document, 'hoodMouseOver', @setupMouseOver
      @on document, 'showToolTip', @buildToolTip
      @on document, 'closeInfoWindow', @hideInfoWindow
      return

  return defineComponent(neighborhoodsOverlay, mobileDetection)

