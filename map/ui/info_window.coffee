'use strict'

define [
  'flight/lib/component',
  'common/ag-utils'
], (
  defineComponent,
  utils
) ->

  infoWindow = ->

    @defaultAttrs
      gMap: {}
      gMarker: {}
      gmapInfoWindows: {}
      currentOpenWindow: {}

    @showInfoWindowOnMarkerClick = (ev, data) ->
      @attr.gMarker = data.gMarker
      @attr.gMap = data.gMap
      @trigger document, 'uiInfoWindowDataRequest', listingId: @attr.gMarker.datumId

    @render = (ev, data) ->
      @closeOpenInfoWindows()
      gInfoWindow = @openInfoWindow(data)
      @wireUpEvents(gInfoWindow)

    @closeOpenInfoWindows = ->
      @attr.currentOpenWindow.close() unless $.isEmptyObject(@attr.currentOpenWindow)

    @openInfoWindow = (data) ->
      gInfoWindow = new google.maps.InfoWindow()
      gInfoWindow.setContent data
      gInfoWindow.open @attr.gMap, @attr.gMarker
      @attr.currentOpenWindow = gInfoWindow

    @wireUpEvents = (gInfoWindow) ->
      google.maps.event.addListener gInfoWindow, 'closeclick', ->
        $(document).trigger 'uiInfoWindowClosed'
      google.maps.event.addListener gInfoWindow, 'domready', =>
        $(document).trigger 'uiInfoWindowRendered', marker: @attr.gMarker, infoWindow: gInfoWindow

    @after 'initialize', ->
      @on document, 'markerClicked', @showInfoWindowOnMarkerClick
      @on document, 'infoWindowDataAvailable', @render
      @on document, 'uiCloseOpenInfoWindows', @closeOpenInfoWindows

  return infoWindow
