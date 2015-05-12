'use strict';
define(['jquery'], function($) {
  var infoWindow;
  infoWindow = function() {
    ({
      currentOpenWindow: null
    });
    this.show = function(ev, data) {
      this.closeOpenInfoWindow();
      this.openInfoWindow(data);
      return this.wireUpEvents(data);
    };
    this.closeOpenInfoWindow = function() {
      if (this.currentOpenWindow) {
        return this.currentOpenWindow.close();
      }
    };
    this.openInfoWindow = function(data) {
      if (this.currentOpenWindow == null) {
        this.currentOpenWindow = new google.maps.InfoWindow();
      }
      this.currentOpenWindow.setContent(data.infoHtml);
      this.currentOpenWindow.open(data.gMap, data.gMarker);
      return this.currentOpenWindow.setPosition(data.gMarker.position);
    };
    this.wireUpEvents = function(data) {
      if (this.currentOpenWindow) {
        google.maps.event.addListenerOnce(this.currentOpenWindow, 'closeclick', function() {
          return $(document).trigger('uiInfoWindowClosed');
        });
        return google.maps.event.addListenerOnce(this.currentOpenWindow, 'domready', (function(_this) {
          return function() {
            return $(document).trigger('uiInfoWindowRendered', {
              listingId: data.gMarker.datumId,
              marker: data.gMarker,
              infoWindow: _this.currentOpenWindow
            });
          };
        })(this));
      }
    };
    return this.after('initialize', function() {
      this.on(document, 'uiShowInfoWindow', this.show);
      return this.on(document, 'uiCloseOpenInfoWindows', this.closeOpenInfoWindow);
    });
  };
  return infoWindow;
});
