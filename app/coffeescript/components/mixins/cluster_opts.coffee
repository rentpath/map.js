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
      clusterFontWeight: 'bold'
      clusterSize: 10

    @_clusterStyles = ->
      url: "#{@assetURL()}#{@attr.clusterURLPath}"
      height: @attr.clusterHeight
      width: @attr.clusterWidth
      textColor: @attr.clusterTextColor
      textSize: @attr.clusterTextSize
      fontWeight: @attr.clusterFontWeight

    @clusterStyleArray = ->
      [@_clusterStyles(), @_clusterStyles(), @_clusterStyles(), @_clusterStyles(), @_clusterStyles()]

    @clusterSize = ->
      @attr.clusterSize

  return clusterOpts
