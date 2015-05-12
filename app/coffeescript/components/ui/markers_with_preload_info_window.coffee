'use strict'

define [
  'flight/lib/component'
  'map/components/ui/markers'
  'map/components/ui/base_info_window'
], (
  defineComponent
  Markers
  InfoWindow
) ->

  markersInfoWindow = ->

    @defaultAttrs
      markerOptions:
        fitBounds: false

    @showInfoWindow = (ev, data) ->
      @trigger document, 'showInfoWindow', id: data.gMarker.datumId

    @after 'initialize', ->
      Markers.attachTo(@node, @attr)
      @on document, 'markerClicked', @showInfoWindow

  defineComponent(markersInfoWindow, InfoWindow)
