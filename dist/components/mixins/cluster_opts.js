define(['map/components/mixins/map_utils'], function(map_utils) {
  var clusterOpts;
  clusterOpts = function() {
    this.defaultAttrs({
      clusterURL: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png",
      clusterHeight: 40,
      clusterWidth: 46,
      clusterTextColor: 'black',
      clusterTextSize: 11,
      clusterFontWeight: 'bold',
      clusterSize: 10
    });
    this._clusterStyles = function() {
      return {
        url: this.attr.clusterURL,
        height: this.attr.clusterHeight,
        width: this.attr.clusterWidth,
        textColor: this.attr.clusterTextColor,
        textSize: this.attr.clusterTextSize,
        fontWeight: this.attr.clusterFontWeight
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
