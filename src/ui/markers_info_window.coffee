'use strict'

define [
  'flight/lib/component',
  '../ui/markers',
  '../ui/info_window'
], (
  defineComponent
  ,Markers
  ,InfoWindow
) ->

  markersInfoWindow = ->

    @defaultAttrs
      markerOptions:
        fitBounds: false

    @after 'initialize', ->
      Markers.attachTo(@node, @attr)

  defineComponent(markersInfoWindow, InfoWindow)
