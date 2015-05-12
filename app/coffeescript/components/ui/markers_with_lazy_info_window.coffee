'use strict'

define [
  'flight/lib/component'
  'map/components/ui/markers'
  'map/components/ui/lazy_info_window'
], (
  defineComponent
  Markers
  LazyInfoWindow
) ->

  markersInfoWindow = ->

    @defaultAttrs
      markerOptions:
        fitBounds: false

    @after 'initialize', ->
      Markers.attachTo(@node, @attr)

  defineComponent(markersInfoWindow, LazyInfoWindow)
