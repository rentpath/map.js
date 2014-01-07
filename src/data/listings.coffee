'use strict'

define [ 'flight/lib/component', '../utils/map_utils', "../utils/distance_conversion",  ], ( defineComponent, map_utils, distanceConversion) ->

  listingsData = ->

    @defaultAttrs
      executeOnce: false
      hybridView: true
      hybridSearchRoute: "/map_view/listings"
      mapPinsRoute:  "/map/pins.json"
      hostname: "www.apartmentguide.com"

    @getListings = (ev, queryData) ->
      return {} if !@isListVisible() || !@attr.hybridView
      @xhr = $.ajax
        url: "#{@attr.hybridSearchRoute}?#{@decodedQueryData(queryData)}"
        success: (data) =>
          @trigger 'listingDataAvailable', htmlData: data, query: queryData
        complete: ->
          map_utils.hideSpinner()

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
          map_utils.hideSpinner()

    @drawerVisible = ->
      $('#hybrid_list').is(':visible')

    @extractRefinementsFromUrl = ->
      $(".pageInfo[name=refinements]").attr("content") or ''

    @extractParamFromUrl = (key)->
      queryParams = location.search.split('&') or []
      regex = key + '=(.*)'
      for param in queryParams
        value = param.match(regex) if param.match(regex)
      if value
        value[1] or ''
      else
        ''

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
        miles: distanceConversion.convertMetersToMiles(data.radius)
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
      qData.refinements = encodeURIComponent(@extractRefinementsFromUrl()) if @extractRefinementsFromUrl().length > 0

      propertyName = @extractParamFromUrl('propertyname')
      qData.propertyname = encodeURIComponent(propertyName) if propertyName.length > 0

      mgtcoid = @extractParamFromUrl('mgtcoid')
      qData.mgtcoid = encodeURIComponent(mgtcoid) if mgtcoid.length > 0
      qData

  return defineComponent(listingsData)
