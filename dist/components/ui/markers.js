'use strict';
define(['jquery', 'flight/lib/component', 'map/components/mixins/clusters', 'map/marker_with_label', 'map/components/mixins/map_utils', 'map/components/mixins/stored_markers', 'primedia_events'], function($, defineComponent, clusters, markerWithLabelFactory, mapUtils, storedMarkers, events) {
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
      MarkerWithLabel: void 0,
      markerLabelOptions: function(datum) {
        return void 0;
      },
      markerOptions: {
        fitBounds: false
      },
      shouldCluster: function(markers) {
        return true;
      },
      mapPin: '',
      mapPinFree: '',
      mapPinShadow: '',
      saveMarkerClick: false
    });
    this.prepend_origin = function(value) {
      return value = "" + (this.assetOriginFromMetaTag()) + value;
    };
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
    this.updateCluster = function(markers) {
      if (this.attr.shouldCluster(markers)) {
        this.initClusterer(this.attr.gMap);
        this.attr.markerClusterer.addMarkers(markers);
        if (this.attr.markerOptions.fitBounds) {
          return this.attr.markerClusterer.fitMapToMarkers();
        }
      }
    };
    this.addMarkers = function(data) {
      var all_markers, i, len, listing, m, ref;
      this.clearAllMarkers();
      all_markers = [];
      ref = data.listings;
      for (i = 0, len = ref.length; i < len; i++) {
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
      this.updateCluster(all_markers);
      this.updateListingsCount();
      return this.trigger('uiSetMarkerInfoWindow');
    };
    this.clearAllMarkers = function() {
      var i, len, marker, ref, ref1;
      if ((ref = this.attr.markerClusterer) != null) {
        ref.clearMarkers();
      }
      ref1 = this.attr.markers;
      for (i = 0, len = ref1.length; i < len; i++) {
        marker = ref1[i];
        this.removeGoogleMarker(marker.googleMarker);
      }
      this.attr.markers = [];
      return this.attr.markersIndex = {};
    };
    this.removeGoogleMarker = function(gmarker) {
      google.maps.event.clearListeners(gmarker, "click");
      gmarker.setMap(null);
      return gmarker = null;
    };
    this.createMarker = function(datum) {
      var options;
      options = this.markerOptions(datum);
      if (options.labelContent) {
        return new this.attr.MarkerWithLabel(options);
      } else {
        return new google.maps.Marker(options);
      }
    };
    this.markerOptions = function(datum) {
      var label, options, viewed;
      viewed = this.storedMarkerExists(datum.id);
      options = {
        position: new google.maps.LatLng(datum.lat, datum.lng),
        map: this.attr.gMap,
        icon: this.iconBasedOnType(this.attr.mapPin, datum, viewed),
        shadow: this.iconBasedOnType(this.attr.mapPinShadow, datum, viewed),
        title: this.markerTitle(datum),
        datum: datum,
        saveMarkerClick: this.attr.saveMarkerClick
      };
      if (label = this.attr.markerLabelOptions(datum)) {
        options.labelContent = label.content;
        if (label.anchor) {
          options.labelAnchor = new google.maps.Point(label.anchor.x, label.anchor.y);
        }
        options.labelClass = label.cssClass;
      }
      return options;
    };
    this.sendCustomMarkerTrigger = function(marker) {
      var _this;
      _this = this;
      google.maps.event.addListener(marker, 'click', function() {
        return $(document).trigger('markerClicked', {
          gMarker: this,
          gMap: _this.attr.gMap,
          viewed: _this.storedMarkerExists(this.datum.id)
        });
      });
      google.maps.event.addListener(marker, 'mouseover', function(marker) {
        return $(document).trigger('markerMousedOver', {
          gMarker: this,
          gMap: _this.attr.gMap,
          viewed: _this.storedMarkerExists(this.datum.id)
        });
      });
      return google.maps.event.addListener(marker, 'mouseout', function(marker) {
        return $(document).trigger('markerMousedOut', {
          gMarker: this,
          gMap: _this.attr.gMap,
          viewed: _this.storedMarkerExists(this.datum.id)
        });
      });
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
    this.deprecatedIconLogic = function(icon, datum) {
      if (icon === this.attr.mapPin) {
        if (datum.free) {
          return this.attr.mapPinFree;
        } else {
          return this.attr.mapPin;
        }
      } else if (icon === this.attr.mapPinShadow) {
        if (datum.free) {
          return "";
        } else {
          return this.attr.mapPinShadow;
        }
      } else {
        return '';
      }
    };
    this.iconBasedOnType = function(icon, datum, viewed) {
      if (typeof icon === "function") {
        return icon(datum, viewed);
      } else if (typeof this.attr.mapPin === "string") {
        return {
          url: this.deprecatedIconLogic(icon, datum)
        };
      } else {
        return icon;
      }
    };
    return this.after('initialize', function() {
      this.attr.MarkerWithLabel = markerWithLabelFactory();
      this.on(document, 'mapRenderedFirst', this.initAttr);
      this.on(document, 'markersUpdateAttr', this.initAttr);
      this.on(document, 'markersDataAvailable', this.render);
      this.on(document, 'animatePin', this.markerAnimation);
      return this.on(document, 'uiMapZoom', this.updateListingsCount);
    });
  };
  return defineComponent(markersOverlay, clusters, mapUtils, storedMarkers);
});
