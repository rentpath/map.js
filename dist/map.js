define(['jquery', 'flight/lib/compose', 'map/components/ui/base_map', 'map/components/ui/markers_with_lazy_info_window', 'map/components/ui/markers_with_preload_info_window', 'map/components/mixins/map_utils', 'map/components/mixins/with_default_attributes', 'jquery.cookie'], function($, compose, baseMap, markersLazyInfoWindow, markersPreloadInfoWindow, mapUtils, withDefaultAttrs) {
  var initialize;
  initialize = function() {
    var infoWindow;
    this.attr = {
      map: {
        canvasId: '#map_canvas',
        geoData: {
          lat: "33.9644",
          lng: "-84.2275"
        },
        gMapOptions: {
          draggable: true,
          panControl: false
        }
      },
      markers: {
        markerOptions: {
          fitBounds: false
        }
      },
      lazyInfoWindows: true
    };
    compose.mixin(this, [withDefaultAttrs, mapUtils]);
    this.overrideAttrsWith(arguments[0]);
    baseMap.attachTo(this.attr.map.canvasId, this.attr.map);
    infoWindow = this.attr.lazyInfoWindows ? markersLazyInfoWindow : markersPreloadInfoWindow;
    return infoWindow.attachTo(this.attr.map.canvasId, this.attr.markers);
  };
  return initialize;
});
