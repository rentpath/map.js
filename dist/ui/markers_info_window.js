'use strict';
define(['flight/lib/component', '../ui/markers', '../ui/info_window'], function(defineComponent, Markers, InfoWindow) {
  var markersInfoWindow;
  markersInfoWindow = function() {
    this.defaultAttrs({
      markerOptions: {
        fitBounds: false
      }
    });
    return this.after('initialize', function() {
      return Markers.attachTo(this.node, this.attr);
    });
  };
  return defineComponent(markersInfoWindow, InfoWindow);
});
