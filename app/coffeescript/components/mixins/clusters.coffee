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

    @mapClusterOptions = ->
      styles: @clusterStyleArray()
      minimumClusterSize: @clusterSize()
      batchSize: if @isMobile() then 200 else null

    @initClusterer = (gMap) ->
      if @attr.markerClusterer
        @attr.markerClusterer.setOptions map: gMap
        return

      @attr.markerClusterer = new MarkerClusterer(gMap, [], @mapClusterOptions())

      google.maps.event.addListener @attr.markerClusterer, 'mouseover', (cluster) ->
        $(document).trigger 'markerClusterMouseOver', cluster: cluster

      google.maps.event.addListener @attr.markerClusterer, 'mouseout', (cluster) ->
        $(document).trigger 'markerClusterMouseOut', cluster: cluster

      google.maps.event.addListener @attr.markerClusterer, 'click', (cluster) ->
        $(document).trigger 'markerClusterClick', cluster: cluster

      google.maps.event.addListener @attr.markerClusterer, 'clusteringend', (clusterer) ->
        $(document).trigger 'markerClusteringEnd', clusterer: clusterer

    @setClusterImage = (ev, data) ->
      @attr.mapPinCluster = data.pinsClusterImage
      @off document, 'clusterImageChange'

    @after 'initialize', ->
      @on document, 'clusterImageChange', @setClusterImage

  return markerClusters
