'use strict'

define [
  'jquery'
  'flight/lib/component'
], (
  $
  defineComponent
) ->

  infoWindowData = ->

    @defaultAttrs
      pinRoute: "/map/pin/"
      pinRefinements: ''

    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@attr.pinRoute}#{data.listingId}?#{@attr.pinRefinements}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
