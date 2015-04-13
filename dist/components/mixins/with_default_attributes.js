define(['jquery', 'flight/lib/compose', 'flight/lib/utils'], function($, compose, mapUtils) {
  var withDefaultAttr;
  withDefaultAttr = function() {
    this.defaultAttr = function() {
      return flight.utils.push(this.defaults, properties, true) || (this.defaults = properties);
    };
    return this.initAttributes = function(attrs) {
      var attr, i, key, len, ref;
      if (attrs == null) {
        attrs = {};
      }
      attr = Object.create(attrs);
      ref = this.defaults;
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        if (!attrs.hasOwnProperty(key)) {
          attr[key] = this.defaults[key];
        }
      }
      return this.attr = attr;
    };
  };
  return withDefaultAttr;
});
