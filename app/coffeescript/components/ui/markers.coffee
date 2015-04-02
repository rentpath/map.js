'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/ui/clusters'
  'primedia_events'
], (
  $
  defineComponent
  clusters
  events
) ->

  markersOverlay = ->

    @defaultAttrs
      searchGeoData: {}
      markers: []
      markersIndex: {}
      gMap: undefined
      markerClusterer: undefined
      markerOptions:
       fitBounds: false

    @initAttr = (ev, data) ->
      @attr.gMap = data.gMap if data.gMap
      @attr.mapPin = data.mapPin if data.mapPin
      @attr.mapPinFree = data.mapPinFree if data.mapPinFree
      @attr.mapPinShadow = data.mapPinShadow if data.mapPinShadow

    @render = (ev, data) ->
      @addMarkers(data)

    @addMarkers = (data) ->
      @attr.markerClusterer.clearMarkers()
      @attr.markers = []
      @attr.markersIndex = {}
      all_markers = []

      for listing in data.listings
        m = @createMarker(listing)
        all_markers.push(m)
        @sendCustomMarkerTrigger(m)
        @attr.markers.push {googleMarker: m, markerData: listing}
        @attr.markersIndex[listing.id] = @attr.markers.length - 1

      @attr.markerClusterer.addMarkers(all_markers)
      @updateListingsCount()
      @attr.markerClusterer.fitMapToMarkers() if @attr.markerOptions.fitBounds
      @trigger 'uiSetMarkerInfoWindow'

    @createMarker = (datum) ->
      new google.maps.Marker(
        position: new google.maps.LatLng(datum.lat, datum.lng)
        map: @attr.gMap
        icon: @iconBasedOnType(datum)
        shadow: @shadowBaseOnType(datum)
        title: @markerTitle(datum) # @setListingTitleBaseOnHost(listing)
        datumId: datum.id
      )

    @sendCustomMarkerTrigger = (marker) ->
      _this = this
      google.maps.event.addListener marker, 'click', ->
        $(document).trigger 'markerClicked', gMarker: @, gMap: _this.attr.gMap

    @currentMarker = () ->
      len = @attrs.markers.length
      @attr.markers[len - 1]

    @markerTitle = (datum) ->
      datum.name || ''

    @markerAnimation = (ev, data) ->
      return unless @attr.markersIndex
      markerIndex = @attr.markersIndex[data.id.slice(7)]
      markerObject = @attr.markers[markerIndex].googleMarker if @attr.markers[markerIndex]
      if markerObject?
        markerObject.setAnimation(data.animation)

    @updateListingsCount = ->
      lCount = @attr.markers.length
      $("#mapview_listing_count").html "Apartments Found: " + lCount

    # These functions should be moved to Listing component
    @iconBasedOnType = (datum) ->
      if datum.free then @attr.mapPinFree else @attr.mapPin

    @shadowBaseOnType = (datum) ->
      if datum.free then "" else @attr.mapPinShadow

    @optimizedBasedOnHost = () ->
      if window.location.hostname.match(/ci\.|local/) then false else true

    @getGeoDataForListing = (listing) ->
      services.getGeoData(urlParameters:
        city: (if listing.propertycity then listing.propertycity.replace(" ", "-") else "")
        state: (if listing.propertystatelong then listing.propertystatelong.replace(" ", "-") else ""))

    @initializeLeadForm = () ->
      if $.isEmptyObject(@attr.searchGeoData)
        leadForm.init @attr.searchGeoData
      else
        $.when(@getGeoDataForListing()).then (geoData) ->
          leadForm.init geoData

    @after 'initialize', ->
      @attr.mapPin = @assetURL() + "/images/nonsprite/map/map_pin_red4.png"
      @attr.mapPinFree = @assetURL() + "/images/nonsprite/map/map_pin_free2.png"
      @attr.mapPinShadow = @assetURL() + "/images/nonsprite/map/map_pin_shadow3.png"

      @on document, 'mapRenderedFirst', @initAttr
      @on document, 'markersUpdateAttr', @initAttr
      @on document, 'markersDataAvailable', @render
      @on document, 'uiMapZoom', @updateListingsCount
      @on document, 'animatePin', @markerAnimation
      return

  return defineComponent(markersOverlay, clusters)
