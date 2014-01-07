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
      Markers.attachTo(@node, markerOptions: @attr.markerOptions)

  defineComponent(markersInfoWindow, InfoWindow)
