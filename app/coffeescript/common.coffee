define [
  "jquery"
  #"dfp"
  "underscore"
  #"common/services"
  #"primedia_events"
  #"common/ag-utils"
  "image-helper"
  "marker-clusterer"
  #"listings/map/ui/listings"
  #"common/templates"
  #'shared/ratings'
  #'pinball_wizard'
  #'jquery-ui' # included for draggable and droppable
], (
  $
  #dfp
  _
  #services
  #events
  #utils
  imageHelper
  markerClusterer
  #MapListingsUI
  #templates
  #ratings
  #pinball
) ->

  class MapCommon
    constructor: (@options) ->
      @location = {}
      latitude  = @_locationFromUrlQuery().latitude || @options.geoData.lat
      longitude = @_locationFromUrlQuery().longitude || @options.geoData.lng
      GoogleMap = googleMapClass()
      @map = new GoogleMap(@options.canvasId, latitude, longitude)
      @_listenForCanvasChanges()

    _listenForCanvasChanges: ->
      $(window).bind "resize",
                     _.debounce(-> $(document).trigger 'mapCanvasResized' , 300)

    _locationFromUrlQuery: ->
      search = window.location.search
      # TODO
      #loc    = utils.queryStringToParams(search)

      if loc?
        @reloadSavedMap = true

        {
          latitude:  parseFloat(loc.latitude)
          longitude: parseFloat(loc.longitude)
          miles:     loc.miles
          zoom:      loc.zoom
        }
      else
        {}

  # Ensure the class is created after google.maps is available
  # Otherwise, CS will attempt to define it when undefined.
  googleMapClass = ->
    class extends google.maps.Map
      constructor: (@container, latitude, longitude) ->
        latitude  or= 33.9411
        longitude or= -84.2136
        zoom =  parseInt($.cookie('map_zoom'), 15)
        @defaultCenter = @_getMapCenter(latitude, longitude)
        @defaultZoom   = zoom || 15

        @mapOptions =
          center: @defaultCenter
          zoom:   @defaultZoom
          minZoom: 1
          mapTypeId: google.maps.MapTypeId.ROADMAP
          scaleControl: true

        super(document.getElementById(@container), @mapOptions)

      _getMapCenter: (latitude, longitude) ->
        new window.google.maps.LatLng(latitude, longitude)

  initMap: (options) ->
    new MapCommon(options.map)

