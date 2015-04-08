'use strict';
define(['jquery', 'flight/lib/component', 'map/components/ui/clusters', 'primedia_events'], function($, defineComponent, clusters, events) {
  var markersOverlay;
  markersOverlay = function() {
    this.defaultAttrs({
      searchGeoData: {},
      listingCountSelector: '#mapview_listing_count',
      listingCountText: 'Apartments Found: ',
      markers: [],
      markersIndex: {},
      gMap: void 0,
      markerClusterer: void 0,
      markerOptions: {
        fitBounds: false
      }
    });
    this.initAttr = function(ev, data) {
      if (data.gMap) {
        this.attr.gMap = data.gMap;
      }
      if (data.mapPin) {
        this.attr.mapPin = data.mapPin;
      }
      if (data.mapPinFree) {
        this.attr.mapPinFree = data.mapPinFree;
      }
      if (data.mapPinShadow) {
        return this.attr.mapPinShadow = data.mapPinShadow;
      }
    };
    this.render = function(ev, data) {
      return this.addMarkers(data);
    };
    this.addMarkers = function(data) {
      var all_markers, i, len1, listing, m, ref;
      this.attr.markerClusterer.clearMarkers();
      this.attr.markers = [];
      this.attr.markersIndex = {};
      all_markers = [];
      ref = data.listings;
      for (i = 0, len1 = ref.length; i < len1; i++) {
        listing = ref[i];
        m = this.createMarker(listing);
        all_markers.push(m);
        this.sendCustomMarkerTrigger(m);
        this.attr.markers.push({
          googleMarker: m,
          markerData: listing
        });
        this.attr.markersIndex[listing.id] = this.attr.markers.length - 1;
      }
      this.attr.markerClusterer.addMarkers(all_markers);
      this.updateListingsCount();
      if (this.attr.markerOptions.fitBounds) {
        this.attr.markerClusterer.fitMapToMarkers();
      }
      return this.trigger('uiSetMarkerInfoWindow');
    };
    this.createMarker = function(datum) {
      return new google.maps.Marker({
        position: new google.maps.LatLng(datum.lat, datum.lng),
        map: this.attr.gMap,
        icon: this.iconBasedOnType(datum),
        shadow: this.shadowBaseOnType(datum),
        title: this.markerTitle(datum),
        datumId: datum.id
      });
    };
    this.sendCustomMarkerTrigger = function(marker) {
      var _this;
      _this = this;
      return google.maps.event.addListener(marker, 'click', function() {
        return $(document).trigger('markerClicked', {
          gMarker: this,
          gMap: _this.attr.gMap
        });
      });
    };
    this.currentMarker = function() {
      var len;
      len = this.attrs.markers.length;
      return this.attr.markers[len - 1];
    };
    this.markerTitle = function(datum) {
      return datum.name || '';
    };
    this.markerAnimation = function(ev, data) {
      var markerIndex, markerObject;
      if (!this.attr.markersIndex) {
        return;
      }
      markerIndex = this.attr.markersIndex[data.id.slice(7)];
      if (this.attr.markers[markerIndex]) {
        markerObject = this.attr.markers[markerIndex].googleMarker;
      }
      if (markerObject != null) {
        return markerObject.setAnimation(data.animation);
      }
    };
    this.updateListingsCount = function() {
      var lCount;
      lCount = this.attr.markers.length;
      return $(this.attr.listingCountSelector).html(this.attr.listingCountText + lCount);
    };
    this.iconBasedOnType = function(datum) {
      if (datum.free) {
        return this.attr.mapPinFree;
      } else {
        return this.attr.mapPin;
      }
    };
    this.shadowBaseOnType = function(datum) {
      if (datum.free) {
        return "";
      } else {
        return this.attr.mapPinShadow;
      }
    };
    this.optimizedBasedOnHost = function() {
      if (window.location.hostname.match(/ci\.|local/)) {
        return false;
      } else {
        return true;
      }
    };
    this.getGeoDataForListing = function(listing) {
      return services.getGeoData({
        urlParameters: {
          city: (listing.propertycity ? listing.propertycity.replace(" ", "-") : ""),
          state: (listing.propertystatelong ? listing.propertystatelong.replace(" ", "-") : "")
        }
      });
    };
    this.initializeLeadForm = function() {
      if ($.isEmptyObject(this.attr.searchGeoData)) {
        return leadForm.init(this.attr.searchGeoData);
      } else {
        return $.when(this.getGeoDataForListing()).then(function(geoData) {
          return leadForm.init(geoData);
        });
      }
    };
    return this.after('initialize', function() {
      this.attr.mapPin = this.assetURL() + "/images/nonsprite/map/map_pin_red4.png";
      this.attr.mapPinFree = this.assetURL() + "/images/nonsprite/map/map_pin_free2.png";
      this.attr.mapPinShadow = this.assetURL() + "/images/nonsprite/map/map_pin_shadow3.png";
      this.on(document, 'mapRenderedFirst', this.initAttr);
      this.on(document, 'markersUpdateAttr', this.initAttr);
      this.on(document, 'markersDataAvailable', this.render);
      this.on(document, 'uiMapZoom', this.updateListingsCount);
      this.on(document, 'animatePin', this.markerAnimation);
    });
  };
  return defineComponent(markersOverlay, clusters);
});
