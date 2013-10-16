'use strict'

define [
  'flight/lib/component',
  'utils'
], (
  defineComponent,
  utils
) ->

  searchMapByAddress = ->

    @defaultAttrs
      icon: utils.assetURL() + "/images/nonsprite/map/map_pin_custom.png"
      addressSearchInputSel: '#searchTextField'
      addressSearchErrorSel: '#address_search_error'            
      addressSearchBar: '#address_search'
      addressSearchLink: '#link_show_address_field'
      autocomplete: undefined

    @initSearchMarker = (ev, data) ->
      @map = data.gMap
      input = @$node.find(@attr.addressSearchInputSel)[0]
      @attr.autocomplete = new google.maps.places.Autocomplete(input)
      @attr.autocomplete.bindTo 'bounds', @map
      @attr.autocomplete.setTypes []
      @handleAddressTextChange()
      @toggleAddressFieldDisplay()
      @setPlaceListener()
      return

    @handleAddressTextChange = () ->
      searchInput = @$node.find(@attr.addressSearchInputSel)
      searchError = @$node.find(@attr.addressSearchErrorSel)
      searchInput.keyup (e) =>
        searchError.slideUp() if (searchError.is(':visible') && e.keyCode != 13)
          
     @toggleAddressFieldDisplay = ->
      searchBar = @$node.find(@attr.addressSearchBar)
      searchLink = @$node.find(@attr.addressSearchLink)
      searchLink.click =>
        if searchBar.is(":visible")
          searchBar.hide 100
          searchLink.text "Add an address"
        else
          searchBar.show 100
          @$node.select(@attr.addressSearchInputSel).focus()
          searchLink.text "Hide address bar"

    @setPlaceListener = () ->
      autocomplete = @attr.autocomplete
      @currentSearchPin = @setSearchPinOptions()
      google.maps.event.addListener autocomplete, "place_changed", =>
        place = autocomplete.getPlace()
        if (place && place.geometry)
          @location = place.geometry.location
          @setAddressPin()
          @searchPinAutoTag()
        else
          @addError("Please Select An Address From the List")

    @addError = (errorText) ->
      $(@attr.addressSearchErrorSel).html(errorText)
      $(@attr.addressSearchErrorSel).slideDown()
      
    @setAddressPin = () ->
      @currentSearchPin.setPosition(@location)
      @map.setCenter @location
      @map.setZoom 13
      @currentSearchPin.setVisible     

    @setSearchPinOptions = () ->
      new google.maps.Marker(
        position: @location
        map: @map
        icon: @attr.icon
        draggable: true
      )

    @searchPinAutoTag = () ->
      obj =
        cg: 'map',
        sg: 'pinDrop',
        item: 'geoCode',
        value: @currentSearchPin.position.lng() + ',' + @currentSearchPin.position.lat(), 
        radius: null, 
        listingCount: null
        ltc: null, 
      WH.fire obj

    @after 'initialize', ->
      @on document, 'mapRenderedFirst', @initSearchMarker

  return defineComponent(searchMapByAddress)