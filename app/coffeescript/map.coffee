define [
  'jquery'
  'flight/lib/compose'
  'map/common'
  'map/components/ui/base_map'
  'map/components/ui/markers_info_window'
  'map/components/mixins/map_utils'
], (
  $
  compose
  theMap
  baseMap
  markerInfoWindow
  mapUtils
) ->

  initialize = ->
    @attr =
      map:
        canvasId: 'map_canvas'
        geoData:
          lat: "33.9644"
          lng: "-84.2275"
        gMapOptions:
          draggable: true
          panControl: false
      markers:
        mapPin:        "/assets/nonsprite/map/map_pin_red4.png"
        mapPinFree:    "/assets/nonsprite/map/map_pin_free2.png"
        mapPinShadow:  "/assets/nonsprite/map/map_pin_shadow3.png"
        mapPinCluster: "/assets/nonsprite/map/map_cluster_red4.png"
        markerOptions:
          fitBounds: true

    # defaultAttrs defined in mixins will trigger this, copying
    # those settings into @attr.

    @defaultAttrs = (attrs) ->
      for k,v of attrs
        @attr[k] = v
      @attr

    compose.mixin(@, [ mapUtils ])

    # merge in overrides.

    @attr = @defaultAttrs(arguments[0])

    # instantiate a google map centered at lat, lng.

    theMap.initMap(@attr)

    # add baseline flight components to the map.

    baseMap.attachTo(@attr.map.canvasId, @attr.map)
    markerInfoWindow.attachTo(@attr.map.canvasId, @attr.markers)

  return initialize
