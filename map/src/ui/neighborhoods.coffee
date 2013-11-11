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
      # where = "LATITUDE >= #{data.lat1} AND LATITUDE <= #{data.lat2} AND LONGITUDE >= #{data.lng1} AND LONGITUDE <= #{data.lng2}"
      # query =
      #   select: "geometry",
      #   from: @attr.tableId,
      #   where: where

      where = "WHERE LATITUDE >= #{data.lat1} AND LATITUDE <= #{data.lat2} AND LONGITUDE >= #{data.lng1} AND LONGITUDE <= #{data.lng2}"

    @addHoodsLayer = (ev, data) ->
      return if !data or !data.gMap or data.gMap.getZoom() < @attr.minimalZommLevel

      @attr.gMap = data.gMap
      @attr.data = data
      @setupLayer(data)
      # @attr.hoodLayer.setMap(@attr.gMap)
      @setupMouseOver()

    @setupMouseOver = () ->
      if !@isMobile() && @attr.enableMouseover
        @buildMouseOverWindow()

    @setupLayer = (data) ->
      query = @hoodQuery(data)

      if @attr.hoodLayer?
        @attr.hoodLayer.setMap(null)
        @attr.hoodLayer.setQuery(query)
      else
        @getData(data)
        # @attr.hoodLayer = new google.maps.FusionTablesLayer(
        #   map: @attr.gMap
        #   query: query
        #   suppressInfoWindows: true
        #   styles: [
        #     polygonOptions: @attr.polygonOptions
        #   ,
        #     where: "HOOD_NAME = '#{@toSpaces(data.hood)}'"
        #     polygonOptions: @attr.polygonOptionsCurrent
        #   ]
        # )
        # @addListeners()
        # @setupToggle()

    @getData = (data) ->
      # Initialize JSONP request
      script = document.createElement("script")
      url = ["https://www.googleapis.com/fusiontables/v1/query?"]
      url.push "sql="
      query = "SELECT geometry, HOOD_NAME, STATENAME, MARKET FROM #{@attr.tableId} #{@hoodQuery(data)}"
      console.log query
      encodedQuery = encodeURIComponent(query)
      url.push encodedQuery
      url.push "&callback=drawMap"
      url.push "&key=#{@attr.apiKey}"

      $.ajax
        url: url.join("")
        dataType: "jsonp"
        success: (data) ->
          @drawMap(data)


    @drawMap = (data) ->
      rows = data["rows"]
      for i of rows
        continue unless rows[i][0]
        newCoordinates = []
        geometries = rows[i][0].geometry
        if geometries
          for j of geometries
            newCoordinates.push window.constructNewCoordinates(geometries)
        else
          newCoordinates = window.constructNewCoordinates(rows[i][1].geometry)
        hoodLayer = new google.maps.Polygon(
          paths: newCoordinates
          fillColor: "#BC8F8F"
          fillOpacity: 0.0
          strokeColor: "#4D4D4D"
          strokeOpacity: 0.8
          strokeWeight: 1
        )

        google.maps.event.addListener hoodLayer, "mouseover", ->
          @setOptions fillOpacity: 1, strokeWeight: 1

        google.maps.event.addListener hoodLayer, "mouseout", ->
          @setOptions fillOpacity: 0.0

        hoodLayer.setMap @attr.gMap


    @constructNewCoordinates = (polygon) ->
      newCoordinates = []
      coordinates = polygon["coordinates"][0]
      for i of coordinates
        newCoordinates.push new google.maps.LatLng(coordinates[i][1], coordinates[i][0])
      newCoordinates


    @setupToggle = ->
      @positionToggleControl()
      @setupToggleAction()

    @setupToggleAction = ->
      if @attr.toggleLink
        @on @attr.toggleLink, 'click', @toggleLayer

    @positionToggleControl = ->
      if @attr.toggleControl
        control = $('<div/>')
        control.append($(@attr.toggleControl))
        @attr.gMap.controls[google.maps.ControlPosition.TOP_RIGHT].push(control[0])

    @toggleLayer = ->
      if @attr.hoodLayer.getMap()
        @attr.hoodLayer.setMap(null)
      else
        @attr.hoodLayer.setMap(@attr.gMap)
        @setupMouseOver()

    @buildMouseOverWindow = ->
      @attr.hoodLayer.enableMapTips
        select: "HOOD_NAME" # list of columns to query, typially need only one column.
        from: @attr.tableId # fusion table name
        geometryColumn: "geometry" # geometry column name
        suppressMapTips: @attr.suppressMapTips # optional, whether to show map tips. default false
        delay: @attr.mouseTipDelay # milliseconds mouse pause before send a server query. default 300.
        tolerance: 8 # tolerance in pixel around mouse. default is 6.
        key: @attr.apiKey
        style: @attr.tipStyle

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
      @on document, 'neighborhoodClicked', @buildInfoWindow
      return

  return defineComponent(neighborhoodsOverlay, mobileDetection)

