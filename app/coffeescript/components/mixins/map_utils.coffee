define [ 'jquery' ], ( $ ) ->

  mapUtils = ->
    @defaultAttrs
      assetHostSelector:    'meta[name="asset_host"]'
      spinnerSelector:      '.spinner'
      refinementsSelector:  '.pageInfo[name="refinements"]'
      propertyNameParam:    'propertyname'
      mgtcoidParam:         'mgtcoid'
      propertyManagementRE: 'property-management'

    @_extractParamFromUrl = (key)->
      queryParams = location.search.split('&') or []
      regex = key + '=(.*)'
      for param in queryParams
        value = param.match(regex) if param.match(regex)

      if value then value[1] or ''

    @limitScaleOf = (number, limit = 4) ->
     number.toFixed(limit)

    @assetURL = ->
      console.log 'assetURL() is deprecated. Use assetOriginFromMetaTag() instead.'
      @assetOriginFromMetaTag()

    @hideSpinner = () ->
      $(@attr.spinnerSelector).hide()

    @getMgtcoId = (pathname = window.location.pathname) ->
      (pathname.match(@attr.propertyManagementRE) and pathname.split('/')[5]) or @_extractParamFromUrl(@attr.mgtcoidParam)

    @getRefinements = ->
      $(@attr.refinementsSelector).attr("content") or ''

    @getPropertyName = ->
      @_extractParamFromUrl(@attr.propertyNameParam)

    @getPriceRange = (refinements) ->
      _ref = _ref1 = undefined
      min_price: (if (_ref = refinements.min_price)? then _ref.value else undefined)
      max_price: (if (_ref1 = refinements.max_price)? then _ref1.value else undefined)

    @assetOriginFromMetaTag = ->
      $(@attr.assetHostSelector).attr('content')

  return mapUtils
