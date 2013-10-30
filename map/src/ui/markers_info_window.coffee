'use strict'

define [
  'flight/lib/component',
  'map/ui/markers',
  'map/ui/info_window'
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
      Markers.attachTo(@node, markerOptions: @attr.markerOptions)

  defineComponent(markersInfoWindow, InfoWindow)
