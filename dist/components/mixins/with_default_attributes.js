define(['jquery', 'flight/lib/compose', 'flight/lib/utils'], function($, compose, flightUtils) {
  var withDefaultAttr;
  withDefaultAttr = function() {
    this.defaultAttrs = function(properties) {
      return flightUtils.push(this.defaults, properties, true) || (this.defaults = properties);
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
    return this.mergeAttributes = function(destination, source) {
      var property, results;
      console.log("in mergeAttributes");
      results = [];
      for (property in source) {
        console.log("  property: " + property);
        if (source[property] && source[property].constructor && source[property].constructor === Object) {
          destination[property] = destination[property] || {};
          console.log("    recurse: " + property);
          results.push(arguments.callee(destination[property], source[property]));
        } else {
          results.push(destination[property] = source[property]);
        }
      }
      return results;
    };
  };
  return withDefaultAttr;
});
