'use strict'

define [
  'underscore'
  'flight/lib/component',
  'lib/fusiontip/fusiontip',
  'lib/accounting/accounting'
], (
  _,
  defineComponent,
  fusionTip,
  accounting
) ->

  neighborhoodsOverlay = ->

    @defaultAttrs
      enableOnboardCalls: false
      tableId: undefined
      apiKey: undefined
      hoodLayer: undefined
      gMap: undefined
      toggleLink: undefined
      toggleControl: undefined
      data: undefined
      infoTemplate: undefined
      polygonOptions:
        fillColor: "fffaf0"
        fillOpacity: 0.1
        strokeColor: "8b8378"
        strokeOpacity: 0.8
        strokeWeight: 1

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
      where = "LATITUDE >= #{data.lat1} AND LATITUDE <= #{data.lat2} AND LONGITUDE >= #{data.lng1} AND LONGITUDE <= #{data.lng2}"
      query =
        select: "geometry",
        from: @attr.tableId,
        where: where

    @addHoodsLayer = (ev, data) ->
      return if !data or !data.gMap or data.gMap.getZoom() < 11

      @attr.gMap = data.gMap
      @attr.data = data

      @setupLayer(data)

      @buildMouseOverWindow()

      @addListeners()

      @setupToggle()

      @attr.hoodLayer.setMap(@attr.gMap)

    @setupLayer = (data) ->
      query = @hoodQuery(data)

      if @attr.hoodLayer?
        @attr.hoodLayer.setMap(null)
        google.maps.event.clearInstanceListeners(@attr.hoodLayer);
        @attr.hoodLayer.setQuery(query)

      @attr.hoodLayer = new google.maps.FusionTablesLayer(
        map: @attr.gMap
        query: query
        styles: [
          polygonOptions: @attr.polygonOptions
        ]
      )

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
        @attr.gMap.controls[google.maps.ControlPosition.TOP_LEFT].push(control[0])

    @toggleLayer = ->
      if @attr.hoodLayer.getMap()
        @attr.hoodLayer.setMap(null);
      else
        @setupLayer(@attr.data)
        @buildMouseOverWindow()
        @addListeners()
        @attr.hoodLayer.setMap(@attr.gMap)

    @buildMouseOverWindow = ->
      @attr.hoodLayer.enableMapTips
        select: "HOOD_NAME, STATENAME" # list of columns to query, typially need only one column.
        from: @attr.tableId # fusion table name
        geometryColumn: "geometry" # geometry column name
        suppressMapTips: false # optional, whether to show map tips. default false
        delay: 200 # milliseconds mouse pause before send a server query. default 300.
        tolerance: 8 # tolerance in pixel around mouse. default is 6.
        key: @attr.apiKey

    @addListeners = ->
      if @attr.infoTemplate
        google.maps.event.addListener @attr.hoodLayer, 'click', (e) =>
          @buildInfoWindow(e)

    @buildInfoWindow = (event) ->
      @buildInfoData(event)
      event.infoWindowHtml = _.template(@attr.infoTemplate, @attr.infoWindowData)

    @buildInfoData = (event) ->
      row = event.row
      unless _.isEmpty(row)
        @attr.infoWindowData.state = row.HOOD_NAME.value
        @attr.infoWindowData.hood = row.STATENAME.value

        @buildOnboardData(row)

    @buildOnboardData = (row) ->
      return unless @attr.enableOnboardCalls

      data = JSON.parse(@getOnboardData(row).responseText)
      unless _.isEmpty(data)
        demographic = data.demographic
        for key, value of @attr.infoWindowData
          if demographic[key]
            @attr.infoWindowData[key] = @formatValue(key, demographic[key])
        console.log @attr.infoWindowData
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

    @after 'initialize', ->
      @on document, 'uiNeighborhoodDataRequest', @addHoodsLayer
      return

  return defineComponent(neighborhoodsOverlay)

