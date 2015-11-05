'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/stored_markers'
], (
  $
  defineComponent
  storedMarkers
) ->

  viewedMapMarkers = ->
    @record = (ev, data) ->
      return unless data.gMarker.saveMarkerClick

      listingId = data.gMarker.datum.id
      @recordMarkerClick(listingId)

    @after 'initialize', ->
      @on document, 'markerClicked', @record

  defineComponent viewedMapMarkers, storedMarkers
