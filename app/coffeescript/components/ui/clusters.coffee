'use strict'

define [
  'flight/lib/compose',
  'flight/lib/component',
  'marker-clusterer',
  'map/components/mixins/mobile_detection',
  'map/components/mixins/cluster_opts'
], (
  compose,
  defineComponent,
  markerClusterer,
  mobileDetection,
  clusterOpts
) ->

  initMarkerClusters = ->

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

    @initClusterer = (ev, data) ->
      @attr.markerClusterer = new MarkerClusterer(data.gMap, [], @mapClusterOptions())

    @setClusterImage = (ev, data) ->
      @attr.mapPinCluster = data.pinsClusterImage
      @off document, 'clusterImageChange'

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initClusterer
      @on document, 'clusterImageChange', @setClusterImage

  return defineComponent(initMarkerClusters, mobileDetection, clusterOpts)
