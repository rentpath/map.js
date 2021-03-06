define [
  'flight/lib/compose'
  'map/components/mixins/map_utils'
], (
  compose
  mapUtils
) ->

  clusterOpts = ->
    compose.mixin(this, [ mapUtils ])

    @defaultAttrs
      clusterURLPath: "/images/nonsprite/map/map_cluster_red4.png"
      clusterHeight: 40
      clusterWidth: 46
      clusterTextColor: 'black'
      clusterTextSize: 11
      clusterFontFamily: 'Arial,sans-serif'
      clusterFontWeight: 'bold'
      clusterSize: 10
      declusterAnimationDuration: 0
      declusterAnimationMarkerThreshold: 0
      declusterAnimationEasing: 'linear'


    @_clusterStyles = ->
      url: @attr.mapPinCluster
      height: @attr.clusterHeight
      width: @attr.clusterWidth
      textColor: @attr.clusterTextColor
      textSize: @attr.clusterTextSize
      fontWeight: @attr.clusterFontWeight
      fontFamily: @attr.clusterFontFamily

    @clusterStyleArray = ->
      [@_clusterStyles(), @_clusterStyles(), @_clusterStyles(), @_clusterStyles(), @_clusterStyles()]

    @clusterSize = ->
      @attr.clusterSize

  return clusterOpts
