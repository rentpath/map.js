"use strict"

requirejs.config
  baseUrl: "bower_components"

  paths:
    map: "../js"
    jquery: "jquery/jquery.min"
    underscore: "underscore/underscore"
    "jquery.cookie": "jquery.cookie/jquery.cookie"
    primedia_events: "primedia_events/primedia-events"
    "marker-clusterer": "marker-clusterer/marker-clusterer"
    "image-helper": "image-helper/image-helper"

require [ 'map/map' ], ( Map ) ->

  #
  # Things to try by changing the MapDemo.mapOptions object in app/index.html:
  #
  #   1. Change canvasId to 'map_canvas_alt' and rerun the demo.

  # initialize and render an empty map.
  new Map(MapDemo.mapOptions)
