'use strict'

define [ 'flight/lib/component', 'third-party/marker-clusterer', 'common/ag-utils' ], ( defineComponent, markerClusterer, Utils) ->

  initMarkerClusters = ->

    @defaultAttrs
      mapPinCluster: Utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      markerClusterer: undefined

    @clearMarkers = () ->
      @unbindMarkers
      @attr.markers.clearMarkers()

    @unbindMarkers = () ->
      $.each @attr.markerClusterer, (index, marker) ->
        google.maps.event.clearListeners marker, "click"

    @mapClusterOptions = () ->
      style =
        height: 40
        url: @attr.mapPinCluster
        width: 46
        textColor: "black"

      styles: [style,style,style,style,style]
      minimumClusterSize: 5

    @initClusterer = (ev, data) ->
      @attr.markerClusterer = new MarkerClusterer(data.gMap, [], @mapClusterOptions())

    @after 'initialize', () ->
      @on document, 'mapRenderedFirst', @initClusterer

  return initMarkerClusters