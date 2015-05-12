'use strict';
define(['jquery', 'flight/lib/compose', 'map/components/ui/base_info_window'], function($, compose, baseInfoWindow) {
  var infoWindow;
  infoWindow = function() {
    compose.mixin(this, [baseInfoWindow]);
    this.defaultAttrs({
      gMap: {},
      gMarker: {}
    });
    this.render = function(ev, data) {
      return $(document).trigger('uiShowInfoWindow', {
        infoHtml: data,
        gMap: this.attr.gMap,
        gMarker: this.attr.gMarker
      });
    };
    this.showInfoWindowOnMarkerClick = function(ev, data) {
      this.attr.gMarker = data.gMarker;
      this.attr.gMap = data.gMap;
      return this.trigger(document, 'uiInfoWindowDataRequest', {
        listingId: this.attr.gMarker.datumId
      });
    };
    return this.after('initialize', function() {
      this.on(document, 'infoWindowDataAvailable', this.render);
      return this.on(document, 'markerClicked', this.showInfoWindowOnMarkerClick);
    });
  };
  return infoWindow;
});
