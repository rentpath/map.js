'use strict'

define [
  'flight/lib/compose'
  'marker-clusterer'
  'map/components/mixins/mobile_detection'
  'map/components/mixins/cluster_opts'
], (
  compose
  markerClusterer
  mobileDetection
  clusterOpts
) ->

  markerClusters = ->

    compose.mixin(@, [mobileDetection, clusterOpts])

    @defaultAttrs
      markerClusterer: undefined

    @clearMarkers = ->
      @unbindMarkers()
      @attr.markers.clearMarkers()

    @unbindMarkers = ->
      for marker in @attr.markerClusterer
        google.maps.event.clearListeners marker, "click"

    @mapClusterOptions = ->
      styles: @clusterStyleArray()
      minimumClusterSize: @clusterSize()
      batchSize: if @isMobile() then 200 else null

    @initClusterer = (gMap) ->
      @attr.markerClusterer ?= new MarkerClusterer(gMap, [], @mapClusterOptions())

    @setClusterImage = (ev, data) ->
      @attr.mapPinCluster = data.pinsClusterImage
      @off document, 'clusterImageChange'

    @after 'initialize', ->
      @on document, 'clusterImageChange', @setClusterImage

  return markerClusters
