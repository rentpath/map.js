define [
  'jquery'
  'flight/lib/compose'
  'map/components/ui/base_map'
  'map/components/ui/markers_info_window'
  'map/components/mixins/map_utils'
  'map/components/mixins/with_default_attributes'
  'map/components/data/viewed_map_markers'
], (
  $
  compose
  baseMap
  markerInfoWindow
  mapUtils
  withDefaultAttrs
  viewedMapMarkers
) ->

  initialize = ->
    @attr =
      map:
        canvasId: '#map_canvas'
        geoData:
          lat: "33.9644"
          lng: "-84.2275"
        gMapOptions:
          draggable: true
          panControl: false
      markers:
        markerOptions:
          fitBounds: false

    # pull in mixins and their defaultAttrs.

    compose.mixin(@, [ withDefaultAttrs, mapUtils ])

    # override @attr with arguments from the caller.

    @overrideAttrsWith(arguments[0])

    # instantiate a google map centered at lat, lng.

    viewedMapMarkers.attachTo(document)
    baseMap.attachTo(@attr.map.canvasId, @attr.map)
    markerInfoWindow.attachTo(@attr.map.canvasId, @attr.markers)

  return initialize
