define [
  'map/components/mixins/map_utils'
], (
  map_utils
) ->

  clusterOpts = ->
    @attributes = ->
      clusterURL: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      clusterHeight: 40
      clusterWidth: 46
      clusterTextColor: 'black'
      clusterTextSize: 11
      clusterFontWeight: 'bold'

    @clusterStyles = ->
      url: @attributes().clusterURL
      height: @attributes().clusterHeight
      width: @attributes().clusterWidth
      textColor: @attributes().clusterTextColor
      textSize: @attributes().clusterTextSize
      fontWeight: @attributes().clusterFontWeight

    @clusterStyleArray = ->
      [@clusterStyles, @clusterStyles, @clusterStyles, @clusterStyles, @clusterStyles]

    @clusterSize = ->
      clusterSize: 10

  return clusterOpts
