'use strict';
define(['jquery', 'underscore', 'flight/lib/component'], function($, _, defineComponent) {
  var infoWindowData;
  infoWindowData = function() {
    this.defaultAttrs({
      pinRoute: "/map/pin/"
    });
    this.getData = function(ev, data) {
      console.log("in getData, listingId=", data.listingId);
      return this.xhr = $.ajax({
        url: "" + this.attr.pinRoute + data.listingId,
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
