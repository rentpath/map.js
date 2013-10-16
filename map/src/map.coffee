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

  initialize = ->
    args = FlightUtils.toArray(arguments)
    mapSel = args.shift()
    addressSearchSel = args.shift()
    geoData = args.pop()
    BaseMap.attachTo(mapSel, {geoData: geoData})
    MarkerInfoWindow.attachTo(mapSel)
    SearchMapByAddress.attachTo(addressSearchSel)

  return initialize