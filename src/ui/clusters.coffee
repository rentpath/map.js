'use strict'

define [
  'flight/lib/compose',
  'flight/lib/component',
  'marker-clusterer',
  '../utils/map_utils',
  '../utils/mobile_detection'
], (
  compose,
  defineComponent,
  markerClusterer,
  map_utils,
  mobileDetection
) ->

  initMarkerClusters = ->
    compose.mixin(@, [mobileDetection])

    @defaultAttrs
      mapPinCluster: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      markerClusterer: undefined
      clusterSize: 10

    @clearMarkers = ->
      @unbindMarkers()
      @attr.markers.clearMarkers()

    @unbindMarkers = ->
      for marker in @attr.markerClusterer
        google.maps.event.clearListeners marker, "click"

    @mapClusterOptions = ->
      batchSize = if @isMobile() then 200 else null
      style =
        height: 40
        url: @attr.mapPinCluster
        width: 46
        textColor: "black"

      styles: [style,style,style,style,style]
      minimumClusterSize: @attr.clusterSize
      batchSize: batchSize

    @initClusterer = (ev, data) ->
      @attr.markerClusterer = new MarkerClusterer(data.gMap, [], @mapClusterOptions())

    @setClusterImage = (ev, data) ->
      @attr.mapPinCluster = data.pinsClusterImage
      @off document, 'clusterImageChange'

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initClusterer
      @on document, 'clusterImageChange', @setClusterImage

  return initMarkerClusters
