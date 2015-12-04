'use strict'

define [
  'jquery'
  'flight/lib/component'
  'map/components/mixins/map_utils'
], (
  $
  defineComponent
  mapUtils
) ->

  infoWindowData = ->

    @defaultAttrs
      pinRoute: "/map/pin/"


    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@attr.pinRoute}#{data.listingId}?#{@getPinRefinements()}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData, mapUtils)
