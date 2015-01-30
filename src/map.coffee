define [
  'jquery'
  'es5-shim'
  'es5-sham'
  'flight/lib/utils'
  './ui/base_map'
  './ui/markers_info_window'
], (
  $
  es5Shim
  es5Sham
  FlightUtils
  BaseMap
  MarkerInfoWindow
) ->

  # EXPECTED ARGUMENTS
  # First element is an options object, sample bellow
  # Add more options needed

  # map:
  #   geoData: geoData
  #   canvas: '#map_canvas'
  #   gMapOptions:
  #     draggable: false
  # hybridList: undefined

  initialize = ->
    args = arguments[0]

    BaseMap.attachTo(args.map.canvas, args.map)
    MarkerInfoWindow.attachTo(args.map.canvas, args.markers)

  return initialize
