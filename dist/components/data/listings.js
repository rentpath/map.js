'use strict';
define(['jquery', 'flight/lib/component', 'map/components/mixins/map_utils', "map/components/mixins/distance_conversion"], function($, defineComponent, mapUtils, distanceConversion) {
  var listingsData;
  listingsData = function() {
    this.defaultAttrs({
      executeOnce: false,
      hybridSearchRoute: '/map_view/listings',
      mapPinsRoute: '/map/pins.json',
      hostname: 'www.apartmentguide.com',
      priceRangeRefinements: {},
      possibleRefinements: ['min_price', 'max_price'],
      pinLimit: void 0
    });
    this.mapConfig = function() {
      return {
        executeOnce: this.attr.executeOnce,
        hybridSearchRoute: this.attr.hybridSearchRoute,
        mapPinsRoute: this.attr.mapPinsRoute,
        hostname: this.attr.hostname,
        priceRangeRefinements: this.attr.priceRangeRefinements,
        possibleRefinements: this.attr.possibleRefinements
      };
    };
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
        complete: (function(_this) {
          return function() {
            return _this.hideSpinner();
          };
        })(this)
      });
    };
    this.decodedQueryData = function(data) {
      return decodeURIComponent($.param(this.queryData(data)));
    };
    this.getMarkers = function(ev, data) {
      data.limit = this.attr.pinLimit;
      return this.xhr = $.ajax({
        url: this.attr.mapPinsRoute + "?" + (this.decodedQueryData(data)),
        success: (function(_this) {
          return function(data) {
            _this.trigger('markersDataAvailable', data);
            return _this.trigger('markersDataAvailableOnce', _this.resetEvents());
          };
        })(this),
        complete: (function(_this) {
          return function() {
            return _this.hideSpinner();
          };
        })(this)
      });
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
      var i, len, mgtcoid, name, priceRange, propertyName, qData, ref, refinements;
      qData = {
        miles: Math.round(this.convertMetersToMiles(data.radius)),
        city: data.city,
        state: data.state,
        zip: data.zip,
        neighborhood: data.hood,
        geoname: data.geoname,
        sort: data.sort
      };
      if (data.latitude != null) {
        qData.lat = data.latitude;
        qData.latitude = data.latitude;
      }
      if (data.longitude != null) {
        qData.lng = data.longitude;
        qData.longitude = data.longitude;
      }
      if (data.lat1 || data.lng1) {
        qData.lat1 = data.lat1;
        qData.lng1 = data.lng1;
      }
      if (data.lat2 || data.lng2) {
        qData.lat2 = data.lat2;
        qData.lng2 = data.lng2;
      }
      if (data.limit != null) {
        qData.limit = data.limit;
      }
      refinements = this.getRefinements();
      if (refinements) {
        qData.refinements = encodeURIComponent(refinements);
      }
      propertyName = this.getPropertyName();
      if (propertyName) {
        qData.propertyname = encodeURIComponent(propertyName);
      }
      mgtcoid = this.getMgtcoId();
      if (mgtcoid) {
        qData.mgtcoid = encodeURIComponent(mgtcoid);
      }
      priceRange = this.getPriceRange(this.attr.priceRangeRefinements);
      ref = this.attr.possibleRefinements;
      for (i = 0, len = ref.length; i < len; i++) {
        name = ref[i];
        if (priceRange[name]) {
          qData[name] = priceRange[name];
        }
      }
      return qData;
    };
  };
  return defineComponent(listingsData, distanceConversion, mapUtils);
});
