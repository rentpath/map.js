'use strict'

define [ 'flight/lib/component', 'common/ag-utils' ], ( defineComponent, utils) ->

  searchMapByAddress = ->

    @defaultAttrs
      icon: utils.assetURL() + "/images/nonsprite/map/map_pin_custom.png"
      addressSearchInputSel: '#searchTextField'
      addressSearchErrorSel: '#address_search_error'            
      addressSearchBar: '#address_search'
      addressSearchLink: '#link_show_address_field'

    @initSearchMarker = () ->
      input = @$node.select(@attr.addressSearchInputSel)[0]
      autocomplete = new google.maps.places.Autocomplete(input)
      autocomplete.bindTo 'bounds', @attr.gMap
      autocomplete.setTypes []
      @handleAddressTextChange()
      @toggleAddressFieldDisplay()
      return

    @handleAddressTextChange = () ->
      searchInput = @$node.select(@attr.addressSearchInputSel)
      searchError = @$node.select(@attr.addressSearchErrorSel)
      searchInput.keyup (e) =>
        @addrSearchError.slideUp() if (searchErrorSel.is(':visible') && e.keyCode != 13)
          
     @toggleAddressFieldDisplay = ->
       searchBar = @$node.select(@attr.addressSearchBar)
       searchLink = @$node.select(@attr.addressSearchLink)
       searchLink.click =>
         if searchBar.is(":visible")
           searchBar.hide 100
           searchLink.text "Add an address"
         else
           searchBar.show 100
           @$node.select(@attr.addressSearchInputSel).focus()
           searchLink.text "Hide address bar"


    @after 'initialize', () ->
      @on document, 'mapRenderedFirst', @initSearchMarker

  return defineComponent(searchMapByAddress)