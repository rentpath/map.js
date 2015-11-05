'use strict'

define [
  'jquery'
  'flight/lib/component'
], (
  $
  defineComponent
) ->

  storedMarkers = ->

    @defaultAttrs
      storageKey: 'viewedMapMarkers'

    @load = ->
      return {} unless Storage?
      JSON.parse(localStorage.getItem(@attr.storageKey)) || {}

    @save = (value) ->
      return unless Storage?
      localStorage.setItem(@attr.storageKey, JSON.stringify(value))

    @storedMarkerExists = (listingId) ->
      @load()[listingId]?

    @recordMarkerClick = (listingId) ->
      viewedListingIds = @load()
      return if viewedListingIds[listingId]?

      viewedListingIds[listingId] = true
      @save(viewedListingIds)

