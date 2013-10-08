'use strict'

define [
  'underscore'
  'flight/lib/component',
  'js/third-party/fusiontip.js'
], (
  _,
  defineComponent,
  fusionTip
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
      polygonOptions:
        fillColor: "fffaf0"
        fillOpacity: 0.1
        strokeColor: "8b8378"
        strokeOpacity: 0.8
        strokeWeight: 1

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
      google.maps.event.addListener @attr.hoodLayer, 'click', (e) =>
        @buildInfoWindow(e)

    @buildInfoWindow = (event) ->
      template = []
      row = event.row

      unless _.isEmpty(row)
        template.push "<p>Neigborhood: #{row.HOOD_NAME.value}</p>" if row.HOOD_NAME
        template.push "<p>State: #{row.STATENAME.value}</p>" if row.STATENAME

        data = @getOnboardHTML(row)
        if data
          template.push data

      event.infoWindowHtml = template.join('')

    @getOnboardHTML = (row) ->
      return undefined unless @attr.enableOnboardCalls

      template = []
      if data = JSON.parse(@getOnboardData(row).responseText)
        unless _.isEmpty(data)
          demographic = data.demographic
          template.push "<p>Population: #{demographic.population}</p>" if demographic.population
          template.push "<p>Growth Since 2000: #{demographic.growth}</p>" if demographic.growth
          template.push "<p>Density: #{demographic.density}</p>" if demographic.density
          template.push "<p>Male Population: #{demographic.males}%</p>" if demographic.males
          template.push "<p>Female Population: #{demographic.females}%</p>" if demographic.females
          template.push "<p>Medium Income: $#{Number(demographic.median_income).toFixed(2)}</p>" if demographic.median_income
          template.push "<p>Average Income: $#{Number(demographic.average_income).toFixed(2)}</p>" if demographic.average_income

      template.join('')

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

