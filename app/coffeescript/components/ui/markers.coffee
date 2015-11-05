'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/clusters'
  'map/components/mixins/map_utils'
  'map/components/mixins/stored_markers'
  'primedia_events'
], (
  $
  defineComponent
  clusters
  mapUtils
  storedMarkers
  events
) ->

  markersOverlay = ->

    @defaultAttrs
      searchGeoData: {}
      listingCountSelector: '#mapview_listing_count'
      listingCountText: 'Apartments Found: '
      markers: []
      markersIndex: {}
      gMap: undefined
      markerClusterer: undefined
      markerOptions:
       fitBounds: false
      shouldCluster: (markers) ->
        true

      mapPin: ''       # can be either a function, Icon options, or url to the pin.
      mapPinFree: ''   # DEPRECATED. See below.
      mapPinShadow: '' # can be either a function, Icon options, or url to the pin.
      saveMarkerClick: false

    @prepend_origin = (value) ->
      value = "#{@assetOriginFromMetaTag()}#{value}"

    @initAttr = (ev, data) ->
      @attr.gMap = data.gMap if data.gMap
      @attr.mapPin = data.mapPin if data.mapPin
      @attr.mapPinFree = data.mapPinFree if data.mapPinFree
      @attr.mapPinShadow = data.mapPinShadow if data.mapPinShadow

    @render = (ev, data) ->
      @addMarkers(data)

    @updateCluster = (markers) ->
      if @attr.shouldCluster(markers)
        @initClusterer @attr.gMap
        @attr.markerClusterer.addMarkers(markers)
        @attr.markerClusterer.fitMapToMarkers() if @attr.markerOptions.fitBounds

    @addMarkers = (data) ->
      @clearAllMarkers()
      all_markers = []

      for listing in data.listings
        m = @createMarker(listing)
        all_markers.push(m)
        @sendCustomMarkerTrigger(m)
        @attr.markers.push {googleMarker: m, markerData: listing}
        @attr.markersIndex[listing.id] = @attr.markers.length - 1

      @updateCluster(all_markers)
      @updateListingsCount()
      @trigger 'uiSetMarkerInfoWindow'

    @clearAllMarkers = ->
      @attr.markerClusterer?.clearMarkers()
      @removeGoogleMarker(marker.googleMarker) for marker in @attr.markers
      @attr.markers = []
      @attr.markersIndex = {}

    @removeGoogleMarker = (gmarker) ->
      google.maps.event.clearListeners gmarker, "click"
      gmarker.setMap(null)
      gmarker = null

    @createMarker = (datum) ->
      saved = @storedMarkerExists(datum.id)

      new google.maps.Marker(
        position: new google.maps.LatLng(datum.lat, datum.lng)
        map: @attr.gMap
        icon: @iconBasedOnType(@attr.mapPin, datum, saved)
        shadow: @iconBasedOnType(@attr.mapPinShadow, datum, saved)
        title: @markerTitle(datum)
        datum: datum
        saveMarkerClick: @attr.saveMarkerClick
      )

    @sendCustomMarkerTrigger = (marker) ->
      _this = this
      google.maps.event.addListener marker, 'click', ->
        $(document).trigger 'markerClicked', gMarker: @, gMap: _this.attr.gMap

      google.maps.event.addListener marker, 'mouseover', (marker) ->
        $(document).trigger 'markerMousedOver', gMarker: @, gMap: _this.attr.gMap

      google.maps.event.addListener marker, 'mouseout', (marker) ->
        $(document).trigger 'markerMousedOut', gMarker: @, gMap: _this.attr.gMap

    @markerTitle = (datum) ->
      datum.name || ''

    @markerAnimation = (ev, data) ->
      return unless @attr.markersIndex

      markerIndex = @attr.markersIndex[data.id.slice(7)]
      markerObject = @attr.markers[markerIndex].googleMarker if @attr.markers[markerIndex]

      markerObject.setAnimation(data.animation) if markerObject?

    # TODO: Move to it's own component. Maybe this is application's responsibility?
    @updateListingsCount = ->
      lCount = @attr.markers.length
      $(@attr.listingCountSelector).html(@attr.listingCountText + lCount)

    @deprecatedIconLogic = (icon, datum) ->
      if icon == @attr.mapPin
        if datum.free then @attr.mapPinFree else @attr.mapPin
      else if icon == @attr.mapPinShadow
        if datum.free then "" else @attr.mapPinShadow
      else
        ''


    @iconBasedOnType = (icon, datum, saved) ->
      if typeof(icon) is "function"
        icon(datum, saved)
      else if typeof(@attr.mapPin) is "string"
        # DEPRECATED: Please pass in a function or object to `@attr.mapPin`
        #             and '@attr.mapPinShadow'.
        { url: @deprecatedIconLogic(icon, datum) }
      else
        icon

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initAttr
      @on document, 'markersUpdateAttr', @initAttr
      @on document, 'markersDataAvailable', @render
      @on document, 'animatePin', @markerAnimation
      # TODO: put into it's own component.
      @on document, 'uiMapZoom', @updateListingsCount

  defineComponent(markersOverlay, clusters, mapUtils, storedMarkers)
