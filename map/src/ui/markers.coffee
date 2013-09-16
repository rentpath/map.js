'use strict'

define [
  'flight/lib/component',
  'map/ui/clusters',
  'common/ag-utils',
  'common/lead-form',
  'common/events',
  'shared/ratings'
], (
  defineComponent
  ,Clusters
  ,utils
  ,leadForm
  ,events
  ,ratings
) ->

  markersOverlay = ->

    @defaultAttrs
       searchGeoData: {}
       markers: []
       markersIndex: {}
       gMap: undefined
       markerClusterer: undefined
       mapPin: utils.assetURL() + "/images/nonsprite/map/map_pin_red4.png"
       mapPinFree: utils.assetURL() + "/images/nonsprite/map/map_pin_free2.png"
       mapPinShadow: utils.assetURL() + "/images/nonsprite/map/map_pin_shadow3.png"

    @initAttr = (ev, data) ->
      @attr.gMap = data.gMap

    @render = (ev, data) ->
      @addMarkers(data)

    @addMarkers = (data) ->
      @attr.markerClusterer.clearMarkers()
      @attr.markers = []
      @attr.markersIndex = {}
      $.each data.listings, (n, d) =>
        m = @createMarker(d)
        @sendCustomMarkerTrigger(m)
        @attr.markerClusterer.addMarker(m)
        @attr.markers.push {googleMarker: m, markerData: d}
        @attr.markersIndex[d.id] = @attr.markers.length - 1
        return
      @updateListingsCount()
      @trigger 'uiSetMarkerInfoWindow'

    @createMarker = (datum) ->
      new google.maps.Marker(
        position: new google.maps.LatLng(datum.lat, datum.lng)
        map: @attr.gMap
        icon: @iconBasedOnType(datum)
        shadow: @shadowBaseOnType(datum)
        optimized: @optimizedBasedOnHost(datum)
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
      lCount = @visibleMarkersCount()
      $("#mapview_listing_count").html "Apartments Found: " + lCount
      lCount

    @visibleMarkersCount = ->
      mapBounds = @attr.gMap.getBounds()
      l = 0
      $.each @attr.markers, (n, marker) ->
        l++ if mapBounds.contains(marker.googleMarker.getPosition())
      l

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
      @on document, 'mapRenderedFirst', @initAttr
      @on document, 'markersDataAvailable', @render
      @on document, 'uiMapZoom', @updateListingsCount
      @on document, 'animatePin', @markerAnimation
      return

  return defineComponent(markersOverlay, Clusters)
