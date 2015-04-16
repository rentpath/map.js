define(['jquery', 'flight/lib/compose', 'map/components/ui/base_map', 'map/components/ui/markers_info_window', 'map/components/mixins/map_utils', 'map/components/mixins/with_default_attributes'], function($, compose, baseMap, markerInfoWindow, mapUtils, withDefaultAttrs) {
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
        mapPin: "/assets/nonsprite/map/map_pin_red4.png",
        mapPinFree: "/assets/nonsprite/map/map_pin_free2.png",
        mapPinShadow: "/assets/nonsprite/map/map_pin_shadow3.png",
        mapPinCluster: "/assets/nonsprite/map/map_cluster_red4.png",
        markerOptions: {
          fitBounds: true
        }
      }
    };
    compose.mixin(this, [withDefaultAttrs, mapUtils]);
    this.overrideAttrsWith(arguments[0]);
    baseMap.attachTo(this.attr.map.canvasId, this.attr.map);
    return markerInfoWindow.attachTo(this.attr.map.canvasId, this.attr.markers);
  };
  return initialize;
});
