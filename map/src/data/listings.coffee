'use strict'

define [ 'flight/lib/component', 'common/ag-utils', "map/utils/distance_conversion",  ], ( defineComponent, utils, distanceConversion) ->

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
        url: "#{@hybridSearchRoute}?#{@decodedQueryData(queryData)}"
        success: (data) =>
          @trigger 'listingDataAvailable', htmlData: data, query: queryData
        complete: ->
          utils.hideSpinner()

    @decodedQueryData = (data) ->
      decodeURIComponent($.param(@queryData(data)))

    @isListVisible = ->
      $('#hybrid_list').is(':visible')

    @getMarkers = (ev, data) ->
      data.sort = 'distance'
      @xhr = $.ajax
        url: "#{@mapPinsRoute}?#{@decodedQueryData(data)}"
        success: (data) =>
          @trigger 'markersDataAvailable', @addTitle data
          @trigger 'markersDataAvailableOnce', @resetEvents()
        complete: ->
          utils.hideSpinner()

    @addTitle = (data) ->
      that = @
      $.each data.listings, (n, d) ->
        d.markerTitle = that.setListingTitleBasedOnHost(d)
      data

    @setListingTitleBasedOnHost = (listing) ->
      if window.location.hostname is @hostname
        listing.name
      else
        listing.name.replace(/[^a-zA-Z0-9]+/g, "_") if listing.name?

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
