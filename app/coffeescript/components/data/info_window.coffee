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


    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@attr.pinRoute}#{data.listingId}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
