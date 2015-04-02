define [
  'map/components/mixins/map_utils'
], (
  map_utils
) ->

  clusterOpts = ->
    @defaultAttrs
      clusterURL: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      clusterHeight: 40
      clusterWidth: 46
      clusterTextColor: 'black'
      clusterTextSize: 11
      clusterFontWeight: 'bold'
      clusterSize: 10

    @_clusterStyles = ->
      url: @attr.clusterURL
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
