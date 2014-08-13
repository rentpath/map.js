define ['jquery'], ($) ->

  _extractParamFromUrl = (key)->
    queryParams = location.search.split('&') or []
    regex = key + '=(.*)'
    for param in queryParams
      value = param.match(regex) if param.match(regex)

    if value then value[1] or ''

  assetURL: () ->
    $('meta[name="asset_host"]').attr('content')

  hideSpinner: () ->
    $('.spinner').hide()

  getMgtcoId: (pathname = window.location.pathname) ->
    (pathname.match('property-management') and pathname.split('/')[5]) or _extractParamFromUrl('mgtcoid')

  getRefinements: ->
    $(".pageInfo[name=refinements]").attr("content") or ''

  getPropertyName: ->
    _extractParamFromUrl('propertyname')

  getPriceRange: (refinements) ->
    _ref = _ref1 = undefined
    min_price: (if (_ref = refinements.min_price)? then _ref.value else undefined)
    max_price: (if (_ref1 = refinements.max_price)? then _ref1.value else undefined)
