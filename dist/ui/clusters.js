'use strict';
define(['flight/lib/compose', 'flight/lib/component', 'marker-clusterer', '../utils/map_utils', '../utils/mobile_detection'], function(compose, defineComponent, markerClusterer, map_utils, mobileDetection) {
  var initMarkerClusters;
  initMarkerClusters = function() {
    compose.mixin(this, [mobileDetection]);
    this.defaultAttrs({
      mapPinCluster: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png",
      markerClusterer: void 0,
      clusterSize: 10,
      clusterTextColor: 'black',
      clusterTextSize: 11,
      clusterFontWeight: 'bold'
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
      var batchSize, style;
      batchSize = this.isMobile() ? 200 : null;
      style = {
        height: 40,
        url: this.attr.mapPinCluster,
        width: 46,
        textColor: this.attr.clusterTextColor,
        textSize: this.attr.clusterTextSize,
        fontWeight: this.attr.clusterFontWeight
      };
      return {
        styles: [style, style, style, style, style],
        minimumClusterSize: this.attr.clusterSize,
        batchSize: batchSize
      };
    };
    this.initClusterer = function(ev, data) {
      return this.attr.markerClusterer = new MarkerClusterer(data.gMap, [], this.mapClusterOptions());
    };
    this.setClusterImage = function(ev, data) {
      this.attr.mapPinCluster = data.pinsClusterImage;
      return this.off(document, 'clusterImageChange');
    };
    return this.after('initialize', function() {
      this.on(document, 'mapRenderedFirst', this.initClusterer);
      return this.on(document, 'clusterImageChange', this.setClusterImage);
    });
  };
  return initMarkerClusters;
});
