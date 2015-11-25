define(['flight/lib/compose', 'map/components/mixins/map_utils'], function(compose, mapUtils) {
  var clusterOpts;
  clusterOpts = function() {
    compose.mixin(this, [mapUtils]);
    this.defaultAttrs({
      clusterURLPath: "/images/nonsprite/map/map_cluster_red4.png",
      clusterHeight: 40,
      clusterWidth: 46,
      clusterTextColor: 'black',
      clusterTextSize: 11,
      clusterFontFamily: 'Arial,sans-serif',
      clusterFontWeight: 'bold',
      clusterSize: 10,
      declusterAnimationDuration: 0,
      declusterAnimationMarkerThreshold: 0,
      declusterAnimationEasing: 'linear'
    });
    this._clusterStyles = function() {
      return {
        url: this.attr.mapPinCluster,
        height: this.attr.clusterHeight,
        width: this.attr.clusterWidth,
        textColor: this.attr.clusterTextColor,
        textSize: this.attr.clusterTextSize,
        fontWeight: this.attr.clusterFontWeight,
        fontFamily: this.attr.clusterFontFamily
      };
    };
    this.clusterStyleArray = function() {
      return [this._clusterStyles(), this._clusterStyles(), this._clusterStyles(), this._clusterStyles(), this._clusterStyles()];
    };
    return this.clusterSize = function() {
      return this.attr.clusterSize;
    };
  };
  return clusterOpts;
});
