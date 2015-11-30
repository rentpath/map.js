'use strict'

define [
  'jquery'
  'flight/lib/component'
], (
  $
  defineComponent
) ->
  storedMarkers = ->

    store = undefined

    @defaultAttrs
      storageKey: 'viewedMapMarkers'

    @localStorageSupported = ->
      Storage?

    @load = ->
      if @localStorageSupported()
        @store ?= JSON.parse(localStorage.getItem(@attr.storageKey)) || {}
      @store

    @save = (values) ->
      return unless @localStorageSupported()
      @store = values
      localStorage.setItem(@attr.storageKey, JSON.stringify(@store))

    @storedMarkerExists = (listingId) ->
      @load()[listingId]?

    @recordMarkerClick = (listingId) ->
      viewedListingIds = @load()
      unless viewedListingIds[listingId]?
        viewedListingIds[listingId] = true
        @save(viewedListingIds)
