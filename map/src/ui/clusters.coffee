'use strict'

define [
  'flight/lib/component',
  'lib/marker-clusterer/marker-clusterer',
  'utils'
], (
  defineComponent,
  markerClusterer,
  Utils
) ->

  initMarkerClusters = ->

    @defaultAttrs
      mapPinCluster: Utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      markerClusterer: undefined

    @clearMarkers = ->
      @unbindMarkers()
      @attr.markers.clearMarkers()
      @teardown()

    @unbindMarkers = ->
      $.each @attr.markerClusterer, (index, marker) ->
        google.maps.event.clearListeners marker, "click"

    @mapClusterOptions = ->
      style =
        height: 40
        url: @attr.mapPinCluster
        width: 46
        textColor: "black"

      styles: [style,style,style,style,style]
      minimumClusterSize: 5

    @initClusterer = (ev, data) ->
      @attr.markerClusterer = new MarkerClusterer(data.gMap, [], @mapClusterOptions())

    @setClusterImage = (ev, data) ->
      @attr.mapPinCluster = data.pinsClusterImage
      @off document, 'clusterImageChange'

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initClusterer
      @on document, 'clusterImageChange', @setClusterImage

  return initMarkerClusters
