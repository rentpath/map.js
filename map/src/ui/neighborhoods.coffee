'use strict'

define [
  'underscore',
  'flight/lib/component',
  'lib/fusiontip/fusiontip',
  'lib/accounting/accounting'
  'map/utils/mobile_detection',
  './withTooltip'
], (
  _,
  defineComponent,
  fusionTip,
  accounting,
  mobileDetection,
  withTooltip
) ->

  # class ToolTip extends google.maps.OverlayView
  #   constructor: (@map, @template) ->


  #   container: $("<div/>",
  #     class: "hood_info_window"
  #   )

  #   position: null
  #   count: null
  #   listener: undefined
  #   offset:
  #     x: 20
  #     y: 20

  #   destroy: ->
  #     @setMap(null)

  #   onAdd: ->
  #     @container.appendTo @getPanes().floatPane

  #   onRemove: ->
  #     @container.remove()

  #   
  #     # probably still need to do something here.

  #   setContent: (data) ->
  #     @container.html(_.template(@template, data))
  #     @setMap(@map)


  #   hide: ->
  #     @container.hide().empty()
  #     google.maps.event.removeListener(@listener)

  #   show: ->
  #     @container.show()

  #   onMouseMove: (latLng) ->
  #     px = @getProjection().fromLatLngToContainerPixel(latLng)
  #     @container.css
  #       left: px.x + @offset.x
  #       top: px.y + @offset.y

  #   updatePosition: (position, overlay) ->
  #     @listener = google.maps.event.addListener overlay, "mousemove", (event) =>
  #       @onMouseMove(event.latLng, overlay)
  #     @show()


  neighborhoodsOverlay = ->

    @defaultAttrs
      fusionApiUrl: "https://www.googleapis.com/fusiontables/v1/query?sql="
      baseInfoHtml: "<strong>Neigborhood: </strong>{{hood}}"
      enableOnboardCalls: false
      enableMouseover: false
      tableId: undefined
      apiKey: undefined
      gMap: undefined
      data: undefined
      infoTemplate: undefined
      polygons: []
      wait: 200
      polygonOptions:
        mouseover:
          strokeColor: "#000"
          strokeOpacity: .5
          strokeWeight: 1
          fillColor: "#000"
          fillOpacity: .2

        mouseout:
          strokeWeight: 0
          fillOpacity: 0
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


    @hoodQuery = (data) ->
      query = ["SELECT geometry, HOOD_NAME, STATENAME, MARKET, LATITUDE, LONGITUDE"]
      query.push "FROM #{@attr.tableId}"
      query.push "WHERE LATITUDE >= #{data.lat1} AND LATITUDE <= #{data.lat2}"
      query.push "AND LONGITUDE >= #{data.lng1} AND LONGITUDE <= #{data.lng2}"
      query.join(' ')

    @addHoodsLayer = (ev, data) ->
      @attr.gMap = data.gMap
      @attr.data = data
      @toolTip = new ToolTip(@attr.gMap) unless @toolTip
      @getKmlData(data)

    @setupMouseOver = (event, data) ->
      if !@isMobile() && @attr.enableMouseover
        @buildInfoWindow(event, data)

    @getKmlData = (data) ->
      query = @hoodQuery(data)
      url = [@attr.fusionApiUrl]
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
      mouseOverOptions = @attr.polygonOptions.mouseover
      mouseOutOptions = @attr.polygonOptions.mouseout

      isCurrentHood = (@attr.data.hood == hoodData.hood)
      initialOptions = if isCurrentHood then mouseOverOptions else mouseOutOptions

      hoodLayer = new google.maps.Polygon(
        _.extend({paths:polygonData}, initialOptions)
      )

      toolTip = @toolTip
      google.maps.event.addListener hoodLayer, "mouseover", (event) ->
        @setOptions(mouseOverOptions)
        $(document).trigger 'hoodMouseOver', { data: hoodData, hoodLayer: hoodLayer }

      google.maps.event.addListener hoodLayer, "click", (event) ->
        data = _.extend(hoodLayer, hoodData, event)
        $(document).trigger 'hoodOnClick', data


      google.maps.event.addListener hoodLayer, "mouseout", ->
        toolTip.hide(hoodLayer)
        unless isCurrentHood
          @setOptions(mouseOutOptions)

      hoodLayer.setMap @attr.gMap
      @attr.polygons.push hoodLayer

      return

    @showInfoWindow = (event, data) ->
      @trigger document, 'uiNHoodInfoWindowDataRequest'
      infoData = @buildOnboardData(data)
      html = _.template(@attr.infoTemplate, infoData)
      @toolTip.setContent(html)

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

    @buildInfoWindow = (event, polygonData) ->
      return polygonData.data unless polygonData.data

      html = _.template(@attr.baseInfoHtml, polygonData.data)
      @toolTip.setContent(html)
      @toolTip.updatePosition(polygonData.hoodLayer)

    @buildOnboardData = (polygonData) ->
      return polygonData unless @attr.enableOnboardCalls

      onboardData = JSON.parse(@getOnboardData(polygonData).responseText)
      data = _.extend(@attr.infoWindowData, polygonData)

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

    @toDashes = (value) ->
      return '' unless value?

      value.replace(' ', '-')

    @toSpaces = (value) ->
      return '' unless value?

      value.replace('-', ' ')

    @after 'initialize', ->
      @on document, 'uiNeighborhoodDataRequest', @addHoodsLayer
      @on document, 'hoodMouseOver', @setupMouseOver
      @on document, 'hoodOnClick', @showInfoWindow
      return

  return defineComponent(neighborhoodsOverlay, mobileDetection, withTooltip)

