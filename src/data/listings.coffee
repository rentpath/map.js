'use strict'

define [
  'jquery',
  'underscore',
  'flight/lib/component',
  '../utils/map_utils',
  "../utils/distance_conversion"
], (
  $,
  _
  defineComponent,
  mapUtils,
  distanceConversion
) ->

  listingsData = ->

    @defaultAttrs
      executeOnce: false
      hybridView: true
      hybridSearchRoute: "/map_view/listings"
      mapPinsRoute:  "/map/pins.json"
      hostname: "www.apartmentguide.com"
      priceRangeRefinements: {}

    @getListings = (ev, queryData) ->
      return {} if !@isListVisible() || !@attr.hybridView
      @xhr = $.ajax
        url: "#{@attr.hybridSearchRoute}?#{@decodedQueryData(queryData)}"
        success: (data) =>
          @trigger 'listingDataAvailable', htmlData: data, query: queryData
        complete: ->
          mapUtils.hideSpinner()

    @decodedQueryData = (data) ->
      decodeURIComponent($.param(@queryData(data)))

    @isListVisible = ->
      $('#hybrid_list').is(':visible')

    @getMarkers = (ev, data) ->
      data.sort = 'distance'
      @xhr = $.ajax
        url: "#{@attr.mapPinsRoute}?#{@decodedQueryData(data)}"
        success: (data) =>
          @trigger 'markersDataAvailable', data
          @trigger 'markersDataAvailableOnce', @resetEvents()
        complete: ->
          mapUtils.hideSpinner()

    @drawerVisible = ->
      $('#hybrid_list').is(':visible')

    @renderListings = (skipFitBounds) ->
      if listings = @_parseListingsFromHtml()
        zutron.getSavedListings()
        listingObjects = @_addListingstoMapUpdate(listings, skipFitBounds)
        @_addInfoWindowsToListings(listingObjects)
        @listing_count = @_listingsCount(listingObjects)

    @parseListingsFromHtml = () ->
      listingData = $('#listingData').attr('data-listingData')
      jListingData = $.parseJSON(listingData)
      listings = if jListingData? then jListingData.listings else {}

    @resetEvents = ->
      if @attr.executeOnce
        @off document, 'uiMarkersDataRequest'
        @off document, 'mapRendered'
        @off document, 'uiMapZoomWithMarkers'

    @after 'initialize', ->
      @on document, 'uiListingDataRequest', @getListings
      @on document, 'uiMarkersDataRequest', @getMarkers
      @on document, 'mapRendered', @getListings
      @on document, 'mapRendered', @getMarkers
      @on document, 'uiMapZoomWithMarkers', @getListings
      @on document, 'uiMapZoomWithMarkers', @getMarkers
      @on document, 'uiMapZoomNoMarkers', @getListings

    @queryData = (data) ->
      qData = {
        lat: data.latitude
        latitude: data.latitude
        lng: data.longitude
        longitude: data.longitude
        miles: Math.round(distanceConversion.convertMetersToMiles(data.radius))
        drawer_visible: @drawerVisible
        lat1: data.lat1
        lng1: data.lng1
        lat2: data.lat2
        lng2: data.lng2
        city: data.city
        state: data.state
        zip: data.zip
        neighborhood: data.hood
        geoname: data.geoname
        sort: data.sort
      }

      refinements = mapUtils.getRefinements()
      qData.refinements = encodeURIComponent(refinements) if refinements

      propertyName = mapUtils.getPropertyName()
      qData.propertyname = encodeURIComponent(propertyName) if propertyName

      mgtcoid = mapUtils.getMgtcoId()
      qData.mgtcoid = encodeURIComponent(mgtcoid) if mgtcoid

      priceRange = mapUtils.getPriceRange(@attr.priceRangeRefinements)
      for name in ['min_price', 'max_price']
        qData[name] = priceRange[name] if priceRange[name]

      qData

  return defineComponent(listingsData)
