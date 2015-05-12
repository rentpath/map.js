'use strict'

define [
  'jquery'
], (
  $
) ->

  infoWindow = ->

    currentOpenWindow: null

    @show = (ev, data) ->
      @closeOpenInfoWindow()
      @openInfoWindow(data)
      @wireUpEvents(data)

    @closeOpenInfoWindow = ->
      @currentOpenWindow.close() if @currentOpenWindow

    @openInfoWindow = (data) ->
      @currentOpenWindow ?= new google.maps.InfoWindow()
      @currentOpenWindow.setContent data.infoHtml
      @currentOpenWindow.open data.gMap, data.gMarker
      # Possible TODO:
      # If the marker is clustered, the above line won't put it
      # in the correct position, so we explicitly set the position
      # below. In that case, would it be better to use the center of the cluster itself?
      # If so, how can we get access to the marker's cluster?
      @currentOpenWindow.setPosition data.gMarker.position

    @wireUpEvents = (data) ->
      if @currentOpenWindow
        google.maps.event.addListenerOnce @currentOpenWindow, 'closeclick', ->
          $(document).trigger 'uiInfoWindowClosed'
        google.maps.event.addListenerOnce @currentOpenWindow, 'domready', =>
          $(document).trigger 'uiInfoWindowRendered', listingId: data.gMarker.datumId, marker: data.gMarker, infoWindow: @currentOpenWindow

    @after 'initialize', ->
      @on document, 'uiShowInfoWindow', @show
      @on document, 'uiCloseOpenInfoWindows', @closeOpenInfoWindow

  return infoWindow
