'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/map_utils'
  'map/components/mixins/distance_conversion'
], (
  $
  defineComponent
  mapUtils
  distanceConversion
) ->

  defaultMap = ->

    @defaultAttrs
      latitude: 33.9411
      longitude: -84.2136
      gMap: {}
      gMapEvents: {'center_changed': false, 'zoom_changed': false, 'max_bounds_changed': false}
      maxBounds: undefined
      infoWindowOpen: false
      overlay: undefined
      draggable: true
      geoData: {}
      gMapOptions:
        draggable: undefined
      pinControlsSelector: '#pin_search_controls'
      pinControlsCloseIconSelector: 'a.icon_close'

    @data = {}

    @after 'initialize', ->
      @on document, 'mapDataAvailable', @initBaseMap
      @on document, 'uiInfoWindowDataRequest', =>
        @attr.infoWindowOpen = true

    @initBaseMap = (ev, data) ->
      @data = data || {}
      @firstRender()

    @firstRender = ->
      google.maps.visualRefresh = true

      @attr.gMap = new google.maps.Map(@node, @defineGoogleMapOptions())

      google.maps.event.addListenerOnce @attr.gMap, 'idle', =>
        @attr.maxBounds = @currentBounds()
        @fireOurMapEventsOnce()
        @handleOurMapEvents()
      @addCustomMarker()

    @fireOurMapEventsOnce = () ->
      @trigger document, 'mapRenderedFirst', @mapRenderedFirstData()
      @trigger document, 'mapRendered',  @mapRenderedFirstData()
      @trigger document, 'uiInitMarkerCluster', @mapChangedData()
      @trigger document, "uiNeighborhoodDataRequest", @mapChangedDataBase()

    @handleOurMapEvents = ->
      google.maps.event.addListener @attr.gMap, 'zoom_changed', =>
        @storeEvent('zoom_changed')
      google.maps.event.addListener @attr.gMap, 'center_changed', =>
        @storeEvent('center_changed')
      google.maps.event.addListener @attr.gMap, 'idle', =>
        @checkForMaxBoundsChange()
        @fireOurMapEvents()

    @storeEvent = (event) ->
      @attr.gMapEvents[event] = true

    @checkForMaxBoundsChange = ->
      newBounds = @currentBounds()
      oldBounds = @attr.maxBounds
      unless oldBounds.contains(newBounds.getNorthEast()) && oldBounds.contains(newBounds.getSouthWest())
        @attr.maxBounds = newBounds
        @storeEvent('max_bounds_changed')

    @fireOurMapEvents = () ->
      eventsHash = @attr.gMapEvents
      if @attr.infoWindowOpen is true
        eventsHash['center_changed'] = false
        eventsHash['max_bounds_changed'] = false

      if eventsHash['max_bounds_changed']
        @trigger document, 'uiMapZoomForListings', @mapChangedData()
        @trigger document, 'uiInitMarkerCluster', @mapChangedData()
        @trigger document, 'mapRendered', @mapChangedData()
        @trigger document, 'uiNeighborhoodDataRequest', @mapChangedDataBase()

      if eventsHash['zoom_changed']
        @trigger document, 'uiMapZoom', @mapChangedData()
      if eventsHash['center_changed']
        @trigger document, 'uiMapCenter', @mapChangedData()

      @resetOurEventHash()

    @resetOurEventHash = () ->
      @attr.gMapEvents['center_changed'] = false
      @attr.gMapEvents['zoom_changed'] = false
      @attr.gMapEvents['max_bounds_changed'] = false
      @attr.infoWindowOpen = false

    @defineGoogleMapOptions = () ->
      geo = @getInitialGeo()
      options =
        center:       new google.maps.LatLng(geo.lat, geo.lng)
        zoom:         @radiusToZoom(@geoDataRadiusMiles())
        mapTypeId:    google.maps.MapTypeId.ROADMAP
        scaleControl: true

      for k, v of @attr.gMapOptions
        options[k] = v

      options

    @radiusToZoom = (radius = 10) ->
      Math.round(14-Math.log(radius)/Math.LN2) + 1

    @latitude = ->
      @attr.latitude = @mapCenter().lat()

    @longitude = ->
      @attr.longitude = @mapCenter().lng()

    @southWestLatitude = ->
      @attr.gMap.getBounds().getSouthWest().lat()

    @southWestLongitude = ->
      @attr.gMap.getBounds().getSouthWest().lng()

    @northEastLatitude = ->
      @attr.gMap.getBounds().getNorthEast().lat()

    @northEastLongitude = ->
      @attr.gMap.getBounds().getNorthEast().lng()

    @radius = ->
      gBounds = @attr.gMap.getBounds()
      southWest = gBounds.getSouthWest()
      west = new google.maps.LatLng(@latitude(), southWest.lng())
      south = new google.maps.LatLng(southWest.lat(), @longitude())
      longitudinalDistance = google.maps.geometry.spherical.computeDistanceBetween(west, @mapCenter())
      latitudinalDistance = google.maps.geometry.spherical.computeDistanceBetween(south, @mapCenter())
      radiusInMeters = Math.max(longitudinalDistance, latitudinalDistance)

    @mapCenter = ->
      gLatLng = @attr.gMap.getCenter()

    @currentBounds = ->
      @attr.gMap.getBounds()

    @addCustomMarker = ->
      @customMarkerDialogClose()

    @customMarkerDialogClose = ->
      $("#{@attr.pinControlsSelector} #{@attr.pinControlsCloseIconSelector}").click =>
        $(@attr.pinControlsSelector).remove()

    @mapRenderedFirstData = ->
      data = @mapChangedData()
      data.zip = @geoData().zip
      data.city = @geoData().city
      data.state = @geoData().state
      data.hood = @geoData().hood
      data

    @mapChangedData = ->
      data = @mapChangedDataBase()
      data.sort = 'distance'
      data

    @mapChangedDataBase = ->
      gMap: @attr.gMap
      latitude: @limitScaleOf(@latitude())
      longitude: @limitScaleOf(@longitude())
      radius: @radius()
      lat1: @limitScaleOf(@southWestLatitude())
      lng1: @limitScaleOf(@southWestLongitude())
      lat2: @limitScaleOf(@northEastLatitude())
      lng2: @limitScaleOf(@northEastLongitude())
      zip: @geoData().zip
      city: @geoData().city
      state: @geoData().state
      hood: @geoData().hood
      hoodDisplayName: @geoData().hood_display_name

    @zoomCircle = ->
      radius = @convertMilesToMeters(@geoDataRadiusMiles())
      circleOptions =
        center: @mapCenter()
        map: @attr.gMap
        radius: radius
        fillOpacity: 0.0
        strokeOpacity: 0.0
      circle = new google.maps.Circle(circleOptions)

    @geoDataRadiusMiles = ->
      @geoData().rad || 10

    @geoData = ->
      @attr.geoData || {}

    @getInitialGeo = ->
      lat: @data.lat || @data.latitude || @attr.latitude
      lng: @data.lng || @data.longitude || @attr.longitude

  return defineComponent(defaultMap, mapUtils, distanceConversion)
