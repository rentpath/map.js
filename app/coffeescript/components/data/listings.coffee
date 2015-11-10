'use strict'

define [
  'jquery'
  'underscore'
  'flight/lib/component'
  'map/components/mixins/map_utils'
  "map/components/mixins/distance_conversion"
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
      hybridSearchRoute: '/map_view/listings'
      mapPinsRoute:  '/map/pins.json'
      hostname: 'www.apartmentguide.com'
      priceRangeRefinements: {}
      possibleRefinements: ['min_price', 'max_price']
      sortByAttribute: 'distance'
      firstRender: false

    @mapConfig = ->
      executeOnce: @attr.executeOnce
      hybridSearchRoute: @attr.hybridSearchRoute
      mapPinsRoute: @attr.mapPinsRoute
      hostname: @attr.hostname
      priceRangeRefinements: @attr.priceRangeRefinements
      possibleRefinements: @attr.possibleRefinements
      sortByAttribute: @attr.sortByAttribute

    @getListings = (ev, queryData) ->
      @xhr = $.ajax
        url: "#{@attr.hybridSearchRoute}?#{@decodedQueryData(queryData)}"
        success: (data) =>
          @trigger 'listingDataAvailable', htmlData: data, query: queryData
        complete: =>
          @hideSpinner()

    @decodedQueryData = (data) ->
      decodeURIComponent($.param(@queryData(data)))

    @getMarkers = (ev, data) ->
      data.sort = @attr.sortByAttribute
      @xhr = $.ajax
        url: "#{@attr.mapPinsRoute}?#{@decodedQueryData(data)}"
        success: (data) =>
          @trigger 'markersDataAvailable', data
          @trigger 'markersDataAvailableOnce', @resetEvents()
        complete: =>
          @hideSpinner()

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
      # we need this for the firt hybrid list query
      # first query needs to be sorted by tears and points
      unless @attr.firstRender
        delete data['sort']
        @attr.firstRender = true

      qData = {
        lat: data.latitude
        latitude: data.latitude
        lng: data.longitude
        longitude: data.longitude
        miles: Math.round(@convertMetersToMiles(data.radius))
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

      refinements = @getRefinements()
      qData.refinements = encodeURIComponent(refinements) if refinements

      propertyName = @getPropertyName()
      qData.propertyname = encodeURIComponent(propertyName) if propertyName

      mgtcoid = @getMgtcoId()
      qData.mgtcoid = encodeURIComponent(mgtcoid) if mgtcoid

      priceRange = @getPriceRange(@attr.priceRangeRefinements)
      for name in @attr.possibleRefinements
        qData[name] = priceRange[name] if priceRange[name]

      qData

  return defineComponent(listingsData, distanceConversion, mapUtils)
