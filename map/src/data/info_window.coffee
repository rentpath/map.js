'use strict'

define ['flight/lib/component', 'underscore', 'common/templates', 'common/ag-utils'], (defineComponent, _, templates, utils) ->

  infoWindowData = ->

    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "/map/pin/" + data.listingId
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->
          utils.hideSpinner()

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)