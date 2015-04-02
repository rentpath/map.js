'use strict'

define [ 'flight/lib/component' ], ( defineComponent ) ->

  clusterOpts = ->

    @clusterURL = ->
      map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
    @clusterHeight = -> 40
    @clusterWidth = -> 46
    @clusterTextColor = -> 'black'
    @clusterTextSize = -> 11
    @clusterFontWeight = -> 'bold'

    @clusterStyles = ->
      url: @clusterURL()
      height: @clusterHeight()
      width: @clusterWidth()
      textColor: @clusterTextColor()
      textSize: @clusterTextSize()
      fontWeight: @clusterFontWeight()

    @clusterStyleArray = ->
      [@clusterStyles, @clusterStyles, @clusterStyles, @clusterStyles, @clusterStyles]

    @clusterSize = ->
      clusterSize: 10

  return clusterOpts
