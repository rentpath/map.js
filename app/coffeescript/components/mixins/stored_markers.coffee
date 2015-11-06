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

    @localStorageSupported = ->
      Storage?

    @load = ->
      return {} unless @localStorageSupported()
      JSON.parse(localStorage.getItem(@attr.storageKey)) || {}

    @save = (value) ->
      return unless @localStorageSupported()
      localStorage.setItem(@attr.storageKey, JSON.stringify(value))

    @storedMarkerExists = (listingId) ->
      @load()[listingId]?

    @recordMarkerClick = (listingId) ->
      viewedListingIds = @load()
      return if viewedListingIds[listingId]?

      viewedListingIds[listingId] = true
      @save(viewedListingIds)

