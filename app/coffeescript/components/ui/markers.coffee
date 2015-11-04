'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/clusters'
  'map/components/mixins/map_utils'
  'primedia_events'
  'map/markerAnimate' # FIXME: move to separate gethub repo?
], (
  $
  defineComponent
  clusters
  mapUtils
  events
  markerAnimate
) ->

  markersOverlay = ->

    @defaultAttrs
      searchGeoData: {}
      listingCountSelector: '#mapview_listing_count'
      listingCountText: 'Apartments Found: '
      markers: []
      markersIndex: {}
      clusteredListings: {}  # keys are listing IDs; values are cluster lat/lng
      needClusterData: false
      markersToAnimate: []
      gMap: undefined
      markerClusterer: undefined
      markerOptions:
       fitBounds: false
      shouldCluster: (markers) ->
        true
      declusterAnimationTime: 0

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
      #if @attr.shouldCluster(markers)  # FIXME: handle map variation 2
      @initClusterer @attr.gMap
      @attr.markerClusterer.addMarkers(markers)
      @attr.markerClusterer.fitMapToMarkers() if @attr.markerOptions.fitBounds

    @addMarkers = (data) ->
      console.log("BEGIN addMarkers", data.listings.length)
      @attr.needClusterData = true
      @clearAllMarkers()
      all_markers = []

      shouldCluster = @attr.shouldCluster(data.listings) # ugh

      for listing in data.listings
        m = @createMarker(listing, shouldCluster)
        all_markers.push(m)
        @sendCustomMarkerTrigger(m)
        @attr.markers.push {googleMarker: m, markerData: listing}
        @attr.markersIndex[listing.id] = @attr.markers.length - 1

      @attr.clusteredListings = {}
      @updateCluster(all_markers)
      @updateListingsCount()
      @trigger 'uiSetMarkerInfoWindow'
      if @attr.markersToAnimate.length
        setTimeout =>
          @animateMarkers()
        , 1000

    @clearAllMarkers = ->
      @attr.markerClusterer?.clearMarkers()
      @removeGoogleMarker(marker.googleMarker) for marker in @attr.markers
      @attr.markers = []
      @attr.markersIndex = {}
      @attr.markersToAnimate = []

    @removeGoogleMarker = (gmarker) ->
      google.maps.event.clearListeners gmarker, "click"
      gmarker.setMap(null)
      gmarker = null

    @createMarker = (datum, shouldCluster) ->
      shadowPin = @shadowBaseOnType(datum)

      shouldAnimate = @shouldAnimate(datum.id, shouldCluster) # gag
      if shouldAnimate
        position = @previouslyClusteredLatLng(datum.id)
      else
        position = new google.maps.LatLng(datum.lat, datum.lng)

      marker = new google.maps.Marker(
        position: position
        map: @attr.gMap
        icon: @iconBasedOnType(datum)
        shadow: shadowPin
        title: @markerTitle(datum)
        datum: datum
      )
      if shouldAnimate
        @attr.markersToAnimate.push(marker)

      marker

    @shouldAnimate = (listingId, shouldCluster) ->
      # FIXME: is there same way we can avoid having to pass in shouldCluster ???
      @attr.declusterAnimationTime && !shouldCluster && @previouslyClusteredLatLng(listingId)

    @previouslyClusteredLatLng = (listingId) ->
      @attr.clusteredListings[listingId]

    @animateMarkers = ->
      console.log("animateMarkers", @attr.markersToAnimate)

      return unless @attr.markersToAnimate.length

      # Uncluster the markers
      @attr.markerClusterer.setOptions map: null

      for marker in @attr.markersToAnimate
        position = new google.maps.LatLng(marker.datum.lat, marker.datum.lng)
        marker.animateTo position,
          duration: @attr.declusterAnimationTime
          #easing: 'easeOutCubic'
          easing: 'linear'

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

    # These functions should be moved to Listing component
    @iconBasedOnType = (datum) ->
      if datum.free then @attr.mapPinFree else @attr.mapPin

    @shadowBaseOnType = (datum) ->
      if datum.free then "" else @attr.mapPinShadow

    @noteClusteredListings = (ev, data) ->
      return unless @attr.needClusterData
      @attr.needClusterData = false
      @attr.clusteredListings = {}
      console.log("BEGIN clusteredListings", @attr.clusteredListings)
      for cluster in data.clusterer.getClusters()
        markers = cluster.getMarkers()
        if markers.length >= cluster.minClusterSize_
          for marker in markers
            @attr.clusteredListings[marker.datum.id] = cluster.getCenter()
      console.log("END clusteredListings", @attr.clusteredListings)

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initAttr
      @on document, 'markersUpdateAttr', @initAttr
      @on document, 'markersDataAvailable', @render
      @on document, 'animatePin', @markerAnimation
      @on document, 'markerClusteringEnd', @noteClusteredListings
      # TODO: put into it's own component.
      @on document, 'uiMapZoom', @updateListingsCount


  return defineComponent(markersOverlay, clusters, mapUtils)
