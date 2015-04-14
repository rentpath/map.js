define(['jquery', 'flight/lib/compose', 'flight/lib/utils'], function($, compose, mapUtils) {
  var withDefaultAttr;
  withDefaultAttr = function() {
    this.defaultAttrs = function(properties) {
      return flight.utils.push(this.defaults, properties, true) || (this.defaults = properties);
    };
    this.initAttributes = function(attrs) {
      var attr, k, ref, v;
      if (attrs == null) {
        attrs = {};
      }
      attr = Object.create(attrs);
      ref = this.defaults;
      for (k in ref) {
        v = ref[k];
        if (!attrs.hasOwnProperty(k)) {
          attr[k] = v;
        }
      }
      return this.attr = attr;
    };
  };
  return withDefaultAttr;
});
