'use strict';
define(['jquery', 'flight/lib/component', 'map/components/mixins/clusters', 'map/marker_with_label', 'map/components/mixins/map_utils', 'map/components/mixins/stored_markers'], function($, defineComponent, clusters, markerWithLabelFactory, mapUtils, storedMarkers) {
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
      var allMarkers, i, id, len, listing, m, marker, previousMarkersIndex, ref;
      previousMarkersIndex = this.attr.markersIndex;
      this.clearAllMarkers();
      allMarkers = [];
      ref = data.listings;
      for (i = 0, len = ref.length; i < len; i++) {
        listing = ref[i];
        m = previousMarkersIndex[listing.id] || this.createMarker(listing);
        delete previousMarkersIndex[listing.id];
        allMarkers.push(m);
        this.sendCustomMarkerTrigger(m);
        this.attr.markers.push({
          googleMarker: m,
          markerData: listing
        });
        this.attr.markersIndex[listing.id] = m;
      }
      for (id in previousMarkersIndex) {
        marker = previousMarkersIndex[id];
        this.removeGoogleMarker(marker);
      }
      previousMarkersIndex = null;
      this.updateCluster(allMarkers);
      this.updateListingsCount();
      return this.trigger('uiSetMarkerInfoWindow');
    };
    this.clearAllMarkers = function() {
      var ref;
      if ((ref = this.attr.markerClusterer) != null) {
        ref.clearMarkers();
      }
      this.attr.markers = [];
      return this.attr.markersIndex = {};
    };
    this.removeGoogleMarker = function(gmarker) {
      var ref;
      google.maps.event.clearListeners(gmarker, "click");
      if ((ref = this.attr.markerClusterer) != null) {
        ref.removeMarker(gmarker);
      }
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
      if (label = this.attr.markerLabelOptions(datum, viewed)) {
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
    this.findMarker = function(id) {
      var ref;
      return (ref = this.attr.markersIndex) != null ? ref[id] : void 0;
    };
    this.markerAnimation = function(ev, data) {
      var marker;
      if (marker = this.findMarker(data.id)) {
        return marker.setAnimation(data.animation);
      }
    };
    this.lookupAndDeliverMarker = function(ev, data) {
      var marker;
      marker = this.findMarker(data.id);
      data.viewed = this.storedMarkerExists(data.id);
      if (marker != null) {
        data.gMarker = marker;
      } else {
        data.error = "id '" + data.id + "' not found in marker list";
      }
      return $(document).trigger('dataMapMarker', data);
    };
    this.updateListingsCount = function() {
      var lCount;
      lCount = this.attr.markers.length;
      return $(this.attr.listingCountSelector).html(this.attr.listingCountText + lCount);
    };
    this.iconBasedOnType = function(icon, datum, viewed) {
      if (typeof icon === "function") {
        return icon(datum, viewed);
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
      this.on(document, 'uiWantsMapMarker', this.lookupAndDeliverMarker);
      return this.on(document, 'uiMapZoom', this.updateListingsCount);
    });
  };
  return defineComponent(markersOverlay, clusters, mapUtils, storedMarkers);
});
