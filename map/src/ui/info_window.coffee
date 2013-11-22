'use strict'

define [
  'flight/lib/component',
  'utils'
], (
  defineComponent,
  utils
) ->

  infoWindow = ->

    currentOpenWindow: null
    eventsWired: false

    @defaultAttrs
      gMap: {}
      gMarker: {}

    @showInfoWindowOnMarkerClick = (ev, data) ->
      @attr.gMarker = data.gMarker
      @attr.gMap = data.gMap
      @trigger document, 'uiInfoWindowDataRequest', listingId: @attr.gMarker.datumId

    @render = (ev, data) ->
      @closeOpenInfoWindow()
      @openInfoWindow(data)
      @wireUpEvents()

    @closeOpenInfoWindow = ->
      @currentOpenWindow.close() if @currentOpenWindow

    @openInfoWindow = (data) ->
      @currentOpenWindow ?= new google.maps.InfoWindow()
      @currentOpenWindow.setContent data
      @currentOpenWindow.open @attr.gMap, @attr.gMarker

    @wireUpEvents = ->
      if @currentOpenWindow && !@eventsWired
        google.maps.event.addListenerOnce @currentOpenWindow, 'closeclick', ->
          $(document).trigger 'uiInfoWindowClosed'
        google.maps.event.addListenerOnce @currentOpenWindow, 'domready', =>
          $(document).trigger 'uiInfoWindowRendered', marker: @attr.gMarker, infoWindow: @currentOpenWindow
        @eventsWired = true

    @after 'initialize', ->
      @on document, 'markerClicked', @showInfoWindowOnMarkerClick
      @on document, 'infoWindowDataAvailable', @render
      @on document, 'uiCloseOpenInfoWindows', @closeOpenInfoWindow

  return infoWindow
