'use strict';
define(['jquery', 'flight/lib/component', 'underscore'], function($, defineComponent, _) {
  var infoWindowData;
  infoWindowData = function() {
    this.defaultAttrs({
      route: "/map/pin/",
      min_and_max: ['min_price', 'max_price'],
      refinements: {}
    });
    this.queryParams = function() {
      var name, obj, results, _ref;
      if (_.isEmpty(this.attr.refinements)) {
        return '';
      }
      results = [];
      _ref = this.attr.refinements;
      for (name in _ref) {
        obj = _ref[name];
        if (_.contains(this.attr.min_and_max, name)) {
          results.push(obj.dim_id + "=" + obj.value);
        } else {
          results.push("refinements=" + obj.dim_name + "-" + obj.dim_id);
        }
      }
      return "?" + results.join("&");
    };
    this.getData = function(ev, data) {
      return this.xhr = $.ajax({
        url: "" + this.attr.route + data.listingId + (this.queryParams()),
        success: (function(_this) {
          return function(ajaxData) {
            return $(document).trigger("infoWindowDataAvailable", ajaxData);
          };
        })(this),
        complete: function() {}
      });
    };
    return this.after('initialize', function() {
      return this.on(document, 'uiInfoWindowDataRequest', this.getData);
    });
  };
  return defineComponent(infoWindowData);
});
