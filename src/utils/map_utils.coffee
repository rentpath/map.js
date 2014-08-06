define ['jquery'], ($) ->

  return {
    assetURL: () ->
      $('meta[name="asset_host"]').attr('content')

    hideSpinner: () ->
      $('.spinner').hide()

    limitScaleOf: (number, limit = 4) ->
      number.toFixed(limit)
  }
