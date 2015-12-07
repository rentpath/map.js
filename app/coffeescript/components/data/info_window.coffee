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
      route: "/map/pin/"
      refinements: ''

    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@attr.route}#{data.listingId}?#{@attr.refinements}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
