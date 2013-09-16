'use strict'

define [
  'flight/lib/component',
  '../utils/distance_conversion'
], (
  defineComponent,
  distanceConversion
) ->

  defaultMap = ->

    @defaultAttrs
      latitude: 33.9411
      longitude: -84.2136
      gMap: {}
      gMapEvents: {'center_changed': false, 'zoom_changed': false}
      infoWindowOpen: false
      overlay: undefined

    @after 'initialize', ->
      @on document, 'mapDataAvailable', @initBaseMap
      @on document, 'mapRendered', @consolidateMapChangeEvents
      @on document, 'mapCanvasResized', @resizeMapContainer
      @on document, 'uiInfoWindowDataRequest', =>
        @attr.infoWindowOpen = true
      return

    @initBaseMap = (ev, data) ->
      @data = data || {}
      @render()

    @consolidateMapChangeEvents = (ev, data) ->
      google.maps.event.addListener data.gMap, 'zoom_changed', =>
        @trigger document, 'uiMapZoom', @mapChangedData()
      google.maps.event.addListener data.gMap, 'dragend', =>
        @trigger document, 'uiMapDrag', @mapChangedData()

    @resizeMapContainer = (ev, data) ->
      @$node.css({ height: data.height, width: data.width })
      google.maps.event.trigger @attr.gMap, 'resize'

    @intervalId = null

    @render = () ->
      @attr.gMap = new google.maps.Map(@node, @defineGoogleMapOptions())
      google.maps.event.addListenerOnce @attr.gMap, 'idle', =>
        @fireOurMapEventsOnce()
        @handleOurMapEvents()
      @addCustomMarker()

    @fireOurMapEventsOnce = () ->
      @addOverlayToMap()
      clearInterval(@intervalId)
      @trigger document, 'mapRenderedFirst', @mapRenderedFirstData()
      @trigger document, 'mapRendered',  @mapRenderedFirstData()
      @trigger document, 'uiInitMarkerCluster', @mapChangedData()

    @handleOurMapEvents = (event_type) ->
      google.maps.event.addListener @attr.gMap, 'zoom_changed', =>
        @storeEvent('zoom_changed')
      google.maps.event.addListener @attr.gMap, 'center_changed', =>
        @storeEvent('center_changed')
      google.maps.event.addListener @attr.gMap, 'idle', =>
        @fireOurMapEvents()
      return

    @storeEvent = (event) ->
      @attr.gMapEvents[event] = true

    @fireOurMapEvents = () ->
      eventsHash = @attr.gMapEvents
      eventsHash['center_changed'] = false if @attr.infoWindowOpen == true
      clearInterval(@intervalId)
      @addOverlayToMap if eventsHash['center_changed'] == true
      @trigger document, 'uiMapZoomForListings', @mapChangedData() if eventsHash['zoom_changed'] == true
      @trigger document, 'mapRendered', @mapChangedData() if eventsHash['center_changed'] == true && @attr.infoWindowOpen == false
      @trigger document, 'uiInitMarkerCluster', @mapChangedData() if eventsHash['center_changed'] == true
      @resetOurEventHash()

    @resetOurEventHash = () ->
      @attr.gMapEvents['zoom_changed'] = false
      @attr.gMapEvents['center_changed'] = false
      @attr.infoWindowOpen = false
      return

    @addOverlayToMap = ->
      @attr.overlay = new google.maps.OverlayView()
      @attr.overlay.draw = ->
      @attr.overlay.setMap @attr.gMap

    @defineGoogleMapOptions = () ->
      lat = @data.latitude || @attr.latitude
      lng = @data.longitude || @attr.longitude
      gCenter = new google.maps.LatLng(lat, lng)
      return {
        center: gCenter
        zoom: @radiusToZoom(@geoDataRadiusMiles())
        minZoom: 1
        mapTypeId: google.maps.MapTypeId.ROADMAP
        scaleControl: true
      }

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

    @addCustomMarker = ->
      @customMarkerDialogClose()

    @customMarkerDialogClose = ->
      $('#pin_search_controls a.icon_close').click =>
        $('#pin_search_controls').remove()

    @mapRenderedFirstData = ->
      data = @mapChangedData()
      data.zip = @geoData().zip
      data.city = @geoData().city
      data.state = @geoData().state
      data.hood = @geoData().hood
      data

    @mapChangedData = ->
      {
        gMap: @attr.gMap
        latitude: @latitude()
        longitude: @longitude()
        radius: @radius()
        lat1: @southWestLatitude()
        lng1: @southWestLongitude()
        lat2: @northEastLatitude()
        lng2: @northEastLongitude()
      }

    @zoomCircle = ->
      radius = distanceConversion.convertMilesToMeters(@geoDataRadiusMiles())
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

  return defineComponent(defaultMap)
