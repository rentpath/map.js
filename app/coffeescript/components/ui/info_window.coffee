'use strict'

define [
  'jquery'
  'flight/lib/component'
], (
  $
  defineComponent
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
      @trigger document, 'uiInfoWindowDataRequest', listingId: @attr.gMarker.datum.id

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
      if @currentOpenWindow
        google.maps.event.addListenerOnce @currentOpenWindow, 'closeclick', ->
          $(document).trigger 'uiInfoWindowClosed'
        google.maps.event.addListenerOnce @currentOpenWindow, 'domready', =>
          $(document).trigger 'uiInfoWindowRendered', listingId: @attr.gMarker.datumId, marker: @attr.gMarker, infoWindow: @currentOpenWindow

    @after 'initialize', ->
      @on document, 'markerClicked', @showInfoWindowOnMarkerClick
      @on document, 'infoWindowDataAvailable', @render
      @on document, 'uiCloseOpenInfoWindows', @closeOpenInfoWindow

  return infoWindow
