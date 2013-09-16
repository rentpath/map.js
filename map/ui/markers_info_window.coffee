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

    @after 'initialize', ->
      Markers.attachTo(@node)

  defineComponent(markersInfoWindow, InfoWindow)
