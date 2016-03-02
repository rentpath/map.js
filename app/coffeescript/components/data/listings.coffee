'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/map_utils'
  "map/components/mixins/distance_conversion"
], (
  $
  defineComponent
  mapUtils
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
      pinLimit: undefined

    @mapConfig = ->
      executeOnce: @attr.executeOnce
      hybridSearchRoute: @attr.hybridSearchRoute
      mapPinsRoute: @attr.mapPinsRoute
      hostname: @attr.hostname
      priceRangeRefinements: @attr.priceRangeRefinements
      possibleRefinements: @attr.possibleRefinements

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
      data.limit = @attr.pinLimit
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
      qData =
        miles: Math.round(@convertMetersToMiles(data.radius))
        city: data.city
        state: data.state
        zip: data.zip
        neighborhood: data.hood
        geoname: data.geoname
        sort: data.sort

      if data.latitude?
        qData.lat = data.latitude
        qData.latitude = data.latitude

      if data.longitude?
        qData.lng = data.longitude
        qData.longitude = data.longitude

      if data.lat1 or data.lng1
        qData.lat1 = data.lat1
        qData.lng1 = data.lng1

      if data.lat2 or data.lng2
        qData.lat2 = data.lat2
        qData.lng2 = data.lng2

      qData.limit = data.limit if data.limit?

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
