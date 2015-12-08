'use strict'

define [
  'jquery'
  'flight/lib/component'
  'underscore'
], (
  $
  defineComponent
  _
) ->

  infoWindowData = ->

    @defaultAttrs
      route: "/map/pin/"
      allowed_filters: ['min_price', 'max_price']
      refinements: {}

    @queryParams = ->
      return '' if _.isEmpty(@attr.refinements)
      results = []
      for name, obj of @attr.refinements
        if _.contains(@attr.allowed_filters, name)
          results.push "#{obj.dim_id}=#{obj.value}"
        else
          results.push "refinements=#{obj.dim_name}-#{obj.dim_id}"
      "?" + results.join("&")

    @getData = (ev, data) ->
      @xhr = $.ajax
        url: "#{@attr.route}#{data.listingId}#{@queryParams()}"
        success: (ajaxData) =>
          $(document).trigger "infoWindowDataAvailable", ajaxData
        complete: ->

    @after 'initialize', ->
      @on document, 'uiInfoWindowDataRequest', @getData

  return defineComponent(infoWindowData)
