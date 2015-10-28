'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/clusters'
  'map/components/mixins/map_utils'
  'primedia_events'
], (
  $
  defineComponent
  clusters
  mapUtils
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
      @attr.markerClusterer?.clearMarkers()
      @attr.markers = []
      @attr.markersIndex = {}
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

    @createMarker = (datum) ->
      shadowPin = @shadowBaseOnType(datum)

      new google.maps.Marker(
        position: new google.maps.LatLng(datum.lat, datum.lng)
        map: @attr.gMap
        icon: @iconBasedOnType(datum)
        shadow: shadowPin
        title: @markerTitle(datum)
        datumId: datum.id
      )

    @sendCustomMarkerTrigger = (marker) ->
      _this = this
      google.maps.event.addListener marker, 'click', ->
        $(document).trigger 'markerClicked', gMarker: @, gMap: _this.attr.gMap

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

    # These functions should be moved to Listing component
    @iconBasedOnType = (datum) ->
      if datum.free then @attr.mapPinFree else @attr.mapPin

    @shadowBaseOnType = (datum) ->
      if datum.free then "" else @attr.mapPinShadow

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initAttr
      @on document, 'markersUpdateAttr', @initAttr
      @on document, 'markersDataAvailable', @render
      @on document, 'animatePin', @markerAnimation
      # TODO: put into it's own component.
      @on document, 'uiMapZoom', @updateListingsCount


  return defineComponent(markersOverlay, clusters, mapUtils)
