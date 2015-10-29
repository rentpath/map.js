'use strict';
define(['flight/lib/compose', 'marker-clusterer', 'map/components/mixins/mobile_detection', 'map/components/mixins/cluster_opts'], function(compose, markerClusterer, mobileDetection, clusterOpts) {
  var markerClusters;
  markerClusters = function() {
    compose.mixin(this, [mobileDetection, clusterOpts]);
    this.defaultAttrs({
      markerClusterer: void 0
    });
    this.clearMarkers = function() {
      this.unbindMarkers();
      return this.attr.markers.clearMarkers();
    };
    this.unbindMarkers = function() {
      var marker, _i, _len, _ref, _results;
      _ref = this.attr.markerClusterer;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        marker = _ref[_i];
        _results.push(google.maps.event.clearListeners(marker, "click"));
      }
      return _results;
    };
    this.mapClusterOptions = function() {
      return {
        styles: this.clusterStyleArray(),
        minimumClusterSize: this.clusterSize(),
        batchSize: this.isMobile() ? 200 : null
      };
    };
    this.initClusterer = function(gMap) {
      var _base;
      return (_base = this.attr).markerClusterer != null ? _base.markerClusterer : _base.markerClusterer = new MarkerClusterer(gMap, [], this.mapClusterOptions());
    };
    this.setClusterImage = function(ev, data) {
      this.attr.mapPinCluster = data.pinsClusterImage;
      return this.off(document, 'clusterImageChange');
    };
    return this.after('initialize', function() {
      return this.on(document, 'clusterImageChange', this.setClusterImage);
    });
  };
  return markerClusters;
});
