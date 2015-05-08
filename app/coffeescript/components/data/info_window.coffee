'use strict'

define [
  'jquery'
  'underscore'
  'flight/lib/component'
], (
  $
  _
  defineComponent
) ->

  infoWindowData = ->

    @defaultAttrs
      pinRoute: "/map/pin/"

    @getData = (ev, data) ->
      console.log "in getData, listingId=", data.listingId
      @xhr = $.ajax
        url: "#{@attr.pinRoute}#{data.listingId}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
