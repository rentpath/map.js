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
      "SELECT geometry, HOOD_NAME, STATENAME, MARKET FROM #{@attr.tableId} #{where}"


    @addHoodsLayer = (ev, data) ->
      return if !data or !data.gMap or data.gMap.getZoom() < @attr.minimalZommLevel

      @attr.gMap = data.gMap
      @attr.data = data
      @getKmlData(data)

    @setupMouseOver = (event, data) ->
      console.log "Hood Mouse Over", data.hood
      @buildMouseOverInfo(data.hood)
      if !@isMobile() && @attr.enableMouseover
        console.log "data", hoodData
        # @buildMouseOverWindow()

    @buildMouseOverInfo = (data) ->
      area = data.hood
      state = data.state
      city = data.city
      formattedData = document.createElement('div')
      formattedData.innerHTML = area + "<br>" + city + ", " + state
      @infoWindow.setContent(formattedData)
      # @infoWindow.setPosition(data.location)
      @infoWindow.open(@attr.gMap)

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
      for i of rows
        continue unless rows[i][0]
        row = rows[i]

        polygonData = @buildPaths(row)
        hoodData = @buildHoodData(row)

        mouseOverOptions = @attr.polyOptions.mouseover
        mouseOutOptions = @attr.polyOptions.mouseout

        isCurrentHood = (@attr.data.hood == hoodData.hood)
        initialOptions = if isCurrentHood then mouseOverOptions else mouseOutOptions
        hoodLayer = new google.maps.Polygon(
          _.extend({paths:polygonData}, initialOptions)
        )

        google.maps.event.addListener hoodLayer, "mouseover", (e)->
          @setOptions(mouseOverOptions)
          $(document).trigger 'hoodMouseOver', { hood: hoodData }

        unless isCurrentHood
          google.maps.event.addListener hoodLayer, "mouseout", ->
            @setOptions(mouseOutOptions)

        hoodLayer.setMap @attr.gMap

        @attr.polygons.push hoodLayer

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
        _.object(['hood', 'state', 'city'], row.slice(1))
      else
        {}

    @addListeners = ->
      if @attr.infoTemplate
        google.maps.event.addListener @attr.hoodLayer, 'click', (e) =>
          $(document).trigger 'neighborhoodClicked', { row: e.row, location: e.latLng }

    @buildInfoWindow = (event, data) ->
      @trigger document, 'uiNHoodInfoWindowDataRequest'
      @buildInfoData(event, data)
      event.infoWindowHtml = _.template(@attr.infoTemplate, @attr.infoWindowData)
      @infoWindow.setContent(event.infoWindowHtml)
      @infoWindow.setPosition(data.location)
      @infoWindow.open(@attr.gMap)

    @buildInfoData = (event, data) ->
      row = data.row
      unless _.isEmpty(row)
        @attr.infoWindowData.state = row.STATENAME.value
        @attr.infoWindowData.hood = row.HOOD_NAME.value

        @buildOnboardData(row)

    @buildOnboardData = (row) ->
      return unless @attr.enableOnboardCalls

      data = JSON.parse(@getOnboardData(row).responseText)
      unless _.isEmpty(data)
        demographic = data.demographic
        for key, value of @attr.infoWindowData
          if demographic[key]
            @attr.infoWindowData[key] = @formatValue(key, demographic[key])

    @formatValue = (key, value) ->
      switch key
        when 'median_income', 'average_income'
          accounting.formatMoney(value)
        when 'population'
          accounting.formatNumber(value)
        else
          value

    @getOnboardData = (row) ->
      return {} if _.isEmpty(row)

      query = []
      query.push "state=#{@toDashes(row.STATENAME.value)}"
      query.push "city=#{@toDashes(row.MARKET.value)}"
      query.push "neighborhood=#{@toDashes(row.HOOD_NAME.value)}"

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
      # @on document, 'neighborhoodClicked', @buildInfoWindow
      return

  return defineComponent(neighborhoodsOverlay, mobileDetection)

