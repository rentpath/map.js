'use strict'

#
# BEWARE: This is not full proof since agent strings can be masqueraded.
#  Depending on your need this may or may not work
#

define [ 'flight/lib/component' ], ( defineComponent ) ->

  clusterOpts = ->

    @clusterStyles = ->
      height: 40
      url: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png"
      width: 46
      textColor: 'black'
      textSize: 11
      fontWeight: 'bold'

    @clusterSize = ->
      clusterSize: 10

  return clusterOpts
