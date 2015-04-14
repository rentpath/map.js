define(['jquery', 'flight/lib/utils'], function($, flightUtils) {
  var withDefaultAttr;
  withDefaultAttr = function() {
    this.defaultAttrs = function(properties, errorOnOverride) {
      if (errorOnOverride == null) {
        errorOnOverride = true;
      }
      if (this.attr != null) {
        return flightUtils.push(this.attr, properties, errorOnOverride);
      } else {
        return this.attr = properties;
      }
    };
    return this.overrideAttrsWith = function(properties) {
      return this.defaultAttrs(properties, false);
    };
  };
  return withDefaultAttr;
});
