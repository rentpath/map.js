'use strict'

define [
  'flight/lib/component'
  'marker-clusterer'
  'map/components/mixins/mobile_detection'
  'map/components/mixins/cluster_opts'
], (
  defineComponent
  markerClusterer
  mobileDetection
  clusterOpts
) ->

  markerClusters = ->

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
      @attr.mapPinCluster = @assetURL() + "/images/nonsprite/map/map_cluster_red4.png"

      @on document, 'mapRenderedFirst', @initClusterer
      @on document, 'clusterImageChange', @setClusterImage

  return defineComponent(markerClusters, mobileDetection, clusterOpts)
