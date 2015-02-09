'use strict';
define(['jquery', 'underscore', 'flight/lib/component', '../utils/map_utils', "../utils/distance_conversion"], function($, _, defineComponent, mapUtils, distanceConversion) {
  var listingsData;
  listingsData = function() {
    this.defaultAttrs({
      executeOnce: false,
      hybridSearchRoute: "/map_view/listings",
      mapPinsRoute: "/map/pins.json",
      hostname: "www.apartmentguide.com",
      priceRangeRefinements: {}
    });
    this.getListings = function(ev, queryData) {
      return this.xhr = $.ajax({
        url: this.attr.hybridSearchRoute + "?" + (this.decodedQueryData(queryData)),
        success: (function(_this) {
          return function(data) {
            return _this.trigger('listingDataAvailable', {
              htmlData: data,
              query: queryData
            });
          };
        })(this),
        complete: function() {
          return mapUtils.hideSpinner();
        }
      });
    };
    this.decodedQueryData = function(data) {
      return decodeURIComponent($.param(this.queryData(data)));
    };
    this.getMarkers = function(ev, data) {
      data.sort = 'distance';
      return this.xhr = $.ajax({
        url: this.attr.mapPinsRoute + "?" + (this.decodedQueryData(data)),
        success: (function(_this) {
          return function(data) {
            _this.trigger('markersDataAvailable', data);
            return _this.trigger('markersDataAvailableOnce', _this.resetEvents());
          };
        })(this),
        complete: function() {
          return mapUtils.hideSpinner();
        }
      });
    };
    this.renderListings = function(skipFitBounds) {
      var listingObjects, listings;
      if (listings = this._parseListingsFromHtml()) {
        zutron.getSavedListings();
        listingObjects = this._addListingstoMapUpdate(listings, skipFitBounds);
        this._addInfoWindowsToListings(listingObjects);
        return this.listing_count = this._listingsCount(listingObjects);
      }
    };
    this.parseListingsFromHtml = function() {
      var jListingData, listingData, listings;
      listingData = $('#listingData').attr('data-listingData');
      jListingData = $.parseJSON(listingData);
      return listings = jListingData != null ? jListingData.listings : {};
    };
    this.resetEvents = function() {
      if (this.attr.executeOnce) {
        this.off(document, 'uiMarkersDataRequest');
        this.off(document, 'mapRendered');
        return this.off(document, 'uiMapZoomWithMarkers');
      }
    };
    this.after('initialize', function() {
      this.on(document, 'uiListingDataRequest', this.getListings);
      this.on(document, 'uiMarkersDataRequest', this.getMarkers);
      this.on(document, 'mapRendered', this.getListings);
      this.on(document, 'mapRendered', this.getMarkers);
      this.on(document, 'uiMapZoomWithMarkers', this.getListings);
      this.on(document, 'uiMapZoomWithMarkers', this.getMarkers);
      return this.on(document, 'uiMapZoomNoMarkers', this.getListings);
    });
    return this.queryData = function(data) {
      var mgtcoid, name, priceRange, propertyName, qData, refinements, _i, _len, _ref;
      qData = {
        lat: data.latitude,
        latitude: data.latitude,
        lng: data.longitude,
        longitude: data.longitude,
        miles: Math.round(distanceConversion.convertMetersToMiles(data.radius)),
        lat1: data.lat1,
        lng1: data.lng1,
        lat2: data.lat2,
        lng2: data.lng2,
        city: data.city,
        state: data.state,
        zip: data.zip,
        neighborhood: data.hood,
        geoname: data.geoname,
        sort: data.sort
      };
      refinements = mapUtils.getRefinements();
      if (refinements) {
        qData.refinements = encodeURIComponent(refinements);
      }
      propertyName = mapUtils.getPropertyName();
      if (propertyName) {
        qData.propertyname = encodeURIComponent(propertyName);
      }
      mgtcoid = mapUtils.getMgtcoId();
      if (mgtcoid) {
        qData.mgtcoid = encodeURIComponent(mgtcoid);
      }
      priceRange = mapUtils.getPriceRange(this.attr.priceRangeRefinements);
      _ref = ['min_price', 'max_price'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        name = _ref[_i];
        if (priceRange[name]) {
          qData[name] = priceRange[name];
        }
      }
      return qData;
    };
  };
  return defineComponent(listingsData);
});
