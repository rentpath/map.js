define(['map/components/mixins/map_utils'], function(map_utils) {
  var clusterOpts;
  clusterOpts = function() {
    this.attributes({
      clusterURL: map_utils.assetURL() + "/images/nonsprite/map/map_cluster_red4.png",
      clusterHeight: 40,
      clusterWidth: 46,
      clusterTextColor: 'black',
      clusterTextSize: 11,
      clusterFontWeight: 'bold'
    });
    this.clusterStyles = function() {
      return {
        url: this.attributes.clusterURL,
        height: this.attributes.clusterHeight,
        width: this.attributes.clusterWidth,
        textColor: this.attributes.clusterTextColor,
        textSize: this.attributes.clusterTextSize,
        fontWeight: this.attributes.clusterFontWeight
      };
    };
    this.clusterStyleArray = function() {
      return [this.clusterStyles, this.clusterStyles, this.clusterStyles, this.clusterStyles, this.clusterStyles];
    };
    return this.clusterSize = function() {
      return {
        clusterSize: 10
      };
    };
  };
  return clusterOpts;
});
