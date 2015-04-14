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

require [
  'jquery'
  'flight/lib/compose'
  'map/map'
  'jquery.cookie'
], (
  $
  compose
  Map
) ->

  new Map()
