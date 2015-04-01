'use strict'

define [
  'flight/lib/compose',
  'flight/lib/component',
  'marker-clusterer',
  'map/components/utils/map_utils',
  'map/components/utils/mobile_detection',
  'map/components/utils/cluster_opts'
], (
  compose,
  defineComponent,
  markerClusterer,
  map_utils,
  mobileDetection,
  clusterOpts
) ->

  initMarkerClusters = ->
    compose.mixin(@, [mobileDetection])
    compose.mixin(@, [clusterOpts])

    @defaultAttrs
      markerClusterer: undefined

    @clearMarkers = ->
      @unbindMarkers()
      @attr.markers.clearMarkers()

    @unbindMarkers = ->
      for marker in @attr.markerClusterer
        google.maps.event.clearListeners marker, "click"

    @mapClusterOptions = ->
      batchSize = if @isMobile() then 200 else null
      style = @clusterStyles()

      styles: [style,style,style,style,style]
      minimumClusterSize: @clusterSize()
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
