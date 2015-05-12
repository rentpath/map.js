'use strict'

define [
  'jquery'
  'flight/lib/compose'
  'map/components/ui/base_info_window'
], (
  $
  compose
  baseInfoWindow
) ->

  infoWindow = ->

    compose.mixin(@, [baseInfoWindow])

    @defaultAttrs
      gMap: {}
      gMarker: {}

    @render = (ev, data) ->
      $(document).trigger 'uiShowInfoWindow', infoHtml: data, gMap: @attr.gMap, gMarker: @attr.gMarker

    @showInfoWindowOnMarkerClick = (ev, data) ->
      @attr.gMarker = data.gMarker
      @attr.gMap = data.gMap
      @trigger document, 'uiInfoWindowDataRequest', listingId: @attr.gMarker.datumId

    @after 'initialize', ->
      @on document, 'infoWindowDataAvailable', @render
      @on document, 'markerClicked', @showInfoWindowOnMarkerClick

  return infoWindow
