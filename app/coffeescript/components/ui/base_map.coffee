'use strict'

define [
  'jquery'
  'underscore'
  'flight/lib/component'
  'map/components/mixins/map_utils'
  'map/components/mixins/distance_conversion'
], (
  $
  _
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
      userChangedMap: false # if the user has panned/zoomed/modified the map

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
        @attachEventListeners()
      @addCustomMarker()

    @fireOurMapEventsOnce = () ->
      @trigger document, 'mapRenderedFirst', @mapState()
      @trigger document, 'mapRendered',  @mapState()
      @trigger document, 'uiInitMarkerCluster', @mapState()
      @trigger document, "uiNeighborhoodDataRequest", @mapState()

    @attachEventListeners = (duration = 250) ->
      google.maps.event.addListener @attr.gMap, 'zoom_changed', _.debounce(=>
        @storeEvent('zoom_changed')
        @checkForMaxBoundsChange()
        @fireOurMapEvents()
      , duration)

      google.maps.event.addListener @attr.gMap, 'center_changed', _.debounce(=>
        @storeEvent('center_changed')
        @checkForMaxBoundsChange()
        @fireOurMapEvents()
      , duration)

    @storeEvent = (event) ->
      @attr.userChangedMap = true
      @attr.gMapEvents[event] = true

    @checkForMaxBoundsChange = ->
      newBounds = @currentBounds()
      oldBounds = @attr.maxBounds
      unless oldBounds.contains(newBounds.getNorthEast()) && oldBounds.contains(newBounds.getSouthWest())
        @attr.maxBounds = newBounds
        @storeEvent('max_bounds_changed')

    @fireOurMapEvents = ->
      eventsHash = @attr.gMapEvents
      if @attr.infoWindowOpen is true
        eventsHash['center_changed'] = false
        eventsHash['max_bounds_changed'] = false

      if eventsHash['max_bounds_changed']
        @trigger document, 'uiMapZoomForListings', @mapState()
        @trigger document, 'uiInitMarkerCluster', @mapState()
        @trigger document, 'mapRendered', @mapState()
        @trigger document, 'uiNeighborhoodDataRequest', @mapState()
      else if eventsHash['zoom_changed']
        @trigger document, 'uiMapZoom', @mapState()
        @trigger document, 'uiListingDataRequest', @mapState()
      else if eventsHash['center_changed']
        @trigger document, 'uiMapCenter', @mapState()
        @trigger document, 'uiListingDataRequest', @mapState()

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
      @attr.gMap.getCenter()

    @currentBounds = ->
      @attr.gMap.getBounds()

    @addCustomMarker = ->
      @customMarkerDialogClose()

    @customMarkerDialogClose = ->
      $("#{@attr.pinControlsSelector} #{@attr.pinControlsCloseIconSelector}").click =>
        $(@attr.pinControlsSelector).remove()

    @mapState = ->
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

      # an empty sort gives control to the app, which is typically tiers and points
      sort: if @attr.userChangedMap then 'distance' else ''

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
