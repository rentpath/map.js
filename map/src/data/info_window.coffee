'use strict'

define ['flight/lib/component', 'underscore', 'common/templates', 'common/ag-utils'], (defineComponent, _, templates, utils) ->

  infoWindowData = ->

    @defaultAttrs
      pinRoute: "/map/pin/"

    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@pinRoute}#{data.listingId}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->
          utils.hideSpinner()

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
