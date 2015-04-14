var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(["jquery", "underscore", "image-helper", "marker-clusterer"], function($, _, imageHelper, markerClusterer) {
  var MapCommon, googleMapClass;
  MapCommon = (function() {
    function MapCommon(options1) {
      var GoogleMap, latitude, longitude;
      this.options = options1;
      this.location = {};
      latitude = this._locationFromUrlQuery().latitude || this.options.geoData.lat;
      longitude = this._locationFromUrlQuery().longitude || this.options.geoData.lng;
      GoogleMap = googleMapClass();
      this.map = new GoogleMap(this.options.canvasId, latitude, longitude);
      this._listenForCanvasChanges();
    }

    MapCommon.prototype._listenForCanvasChanges = function() {
      return $(window).bind("resize", _.debounce(function() {
        return $(document).trigger('mapCanvasResized', 300);
      }));
    };

    MapCommon.prototype._locationFromUrlQuery = function() {
      var search;
      search = window.location.search;
      if (typeof loc !== "undefined" && loc !== null) {
        this.reloadSavedMap = true;
        return {
          latitude: parseFloat(loc.latitude),
          longitude: parseFloat(loc.longitude),
          miles: loc.miles,
          zoom: loc.zoom
        };
      } else {
        return {};
      }
    };

    return MapCommon;

  })();
  googleMapClass = function() {
    return (function(superClass) {
      extend(_Class, superClass);

      function _Class(container, latitude, longitude) {
        var zoom;
        this.container = container;
        latitude || (latitude = 33.9411);
        longitude || (longitude = -84.2136);
        zoom = parseInt($.cookie('map_zoom'), 15);
        this.defaultCenter = this._getMapCenter(latitude, longitude);
        this.defaultZoom = zoom || 15;
        this.mapOptions = {
          center: this.defaultCenter,
          zoom: this.defaultZoom,
          minZoom: 1,
          mapTypeId: google.maps.MapTypeId.ROADMAP,
          scaleControl: true
        };
        _Class.__super__.constructor.call(this, document.getElementById(this.container), this.mapOptions);
      }

      _Class.prototype._getMapCenter = function(latitude, longitude) {
        return new window.google.maps.LatLng(latitude, longitude);
      };

      return _Class;

    })(google.maps.Map);
  };
  return {
    initMap: function(options) {
      return new MapCommon(options.map);
    }
  };
});
