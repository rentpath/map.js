define [
  'jquery'
  ,'es5-shim/lib/es5-shim'
  ,'es5-shim/lib/es5-sham'
  ,'flight/lib/utils'
  ,'map/ui/base_map'
  ,'map/ui/markers_info_window'
  ,'map/ui/search_map_by_address'
], (
  $
  ,es5Shim
  ,es5Sham
  ,FlightUtils
  ,BaseMap
  ,MarkerInfoWindow
  ,SearchMapByAddress
) ->

  # EXPECTED ARGUMENTS
  # First element is an options object, sample bellow
  # Add more options needed

  # map:
  #   geoData: geoData
  #   canvas: '#map_canvas'
  #   gMapOptions:
  #     draggable: false
  # addressBar: undefined
  # hybridList: undefined

  initialize = ->
    args = arguments[0]

    BaseMap.attachTo(args.map.canvas, args.map)
    MarkerInfoWindow.attachTo(args.map.canvas)
    SearchMapByAddress.attachTo(args.addressBar.selector) if args.addressBar

  return initialize
