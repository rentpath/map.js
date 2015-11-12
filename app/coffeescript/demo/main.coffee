"use strict"

requirejs.config
  baseUrl: "bower_components"

  paths:
    map: "../js"
    jquery: "jquery/jquery.min"
    "marker-clusterer": "marker-clusterer/marker-clusterer"

require [
  'jquery'
  'map/map'
], (
  $
  Map
) ->

  #
  # Things to try by changing the MapDemo.mapOptions object in app/index.html:
  #
  #   1. Change canvasId to 'map_canvas_alt' and rerun the demo.

  # initialize and render an empty map.
  new Map(MapDemo.mapOptions)

  $(document).trigger('mapDataAvailable')
