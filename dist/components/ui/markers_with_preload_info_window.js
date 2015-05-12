'use strict';
define(['flight/lib/component', 'map/components/ui/markers', 'map/components/ui/base_info_window'], function(defineComponent, Markers, InfoWindow) {
  var markersInfoWindow;
  markersInfoWindow = function() {
    this.defaultAttrs({
      markerOptions: {
        fitBounds: false
      }
    });
    this.showInfoWindow = function(ev, data) {
      return this.trigger(document, 'showInfoWindow', {
        id: data.gMarker.datumId
      });
    };
    return this.after('initialize', function() {
      Markers.attachTo(this.node, this.attr);
      return this.on(document, 'markerClicked', this.showInfoWindow);
    });
  };
  return defineComponent(markersInfoWindow, InfoWindow);
});
