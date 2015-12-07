'use strict';
define(['jquery', 'flight/lib/component'], function($, defineComponent) {
  var infoWindowData;
  infoWindowData = function() {
    this.defaultAttrs({
      route: "/map/pin/",
      refinements: ''
    });
    this.getData = function(ev, data) {
      return this.xhr = $.ajax({
        url: "" + this.attr.route + data.listingId + "?" + this.attr.refinements,
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
