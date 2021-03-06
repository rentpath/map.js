define(['jquery', 'flight/lib/compose', 'map/components/ui/base_map', 'map/components/ui/markers_info_window', 'map/components/mixins/map_utils', 'map/components/mixins/with_default_attributes', 'map/components/data/viewed_map_markers'], function($, compose, baseMap, markerInfoWindow, mapUtils, withDefaultAttrs, viewedMapMarkers) {
  var initialize;
  initialize = function() {
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
      }
    };
    compose.mixin(this, [withDefaultAttrs, mapUtils]);
    this.overrideAttrsWith(arguments[0]);
    viewedMapMarkers.attachTo(document);
    baseMap.attachTo(this.attr.map.canvasId, this.attr.map);
    return markerInfoWindow.attachTo(this.attr.map.canvasId, this.attr.markers);
  };
  return initialize;
});
