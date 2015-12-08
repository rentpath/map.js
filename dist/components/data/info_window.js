'use strict';
var __hasProp = {}.hasOwnProperty;

define(['jquery', 'flight/lib/component', 'underscore'], function($, defineComponent, _) {
  var infoWindowData;
  infoWindowData = function() {
    this.defaultAttrs({
      route: "/map/pin/",
      allowed_filters: ['min_price', 'max_price'],
      refinements: {}
    });
    this.formatRefinements = function(results) {
      if (_.isEmpty(results.names)) {
        return "";
      }
      return "refinements=" + (results.names.join('-')) + "-" + (results.ids.join('+'));
    };
    this.formatFilters = function(filters, names) {
      if (_.isEmpty(filters)) {
        return "";
      }
      if (_.isEmpty(names)) {
        return filters.join('&');
      } else {
        return "&" + (filters.join('&'));
      }
    };
    this.paramData = function() {
      var name, obj, results, _ref;
      results = {
        names: [],
        ids: [],
        filters: []
      };
      _ref = this.attr.refinements;
      for (name in _ref) {
        if (!__hasProp.call(_ref, name)) continue;
        obj = _ref[name];
        if (_.contains(this.attr.allowed_filters, name)) {
          results.filters.push(obj.dim_id + "=" + obj.value);
        } else {
          results.names.push(obj.dim_name);
          results.ids.push(obj.dim_id);
        }
      }
      return results;
    };
    this.queryString = function(results) {
      return "?" + (this.formatRefinements(results)) + (this.formatFilters(results.filters, results.names));
    };
    this.queryParams = function() {
      if (_.isEmpty(this.attr.refinements)) {
        return "";
      }
      return this.queryString(this.paramData());
    };
    this.getData = function(ev, data) {
      var paramData;
      paramData = this.paramData();
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
