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
      var i, len, marker, ref, results;
      ref = this.attr.markerClusterer;
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        marker = ref[i];
        results.push(google.maps.event.clearListeners(marker, "click"));
      }
      return results;
    };
    this.mapClusterOptions = function() {
      return {
        styles: this.clusterStyleArray(),
        minimumClusterSize: this.clusterSize(),
        batchSize: this.isMobile() ? 200 : null
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
  return markerClusters;
});
