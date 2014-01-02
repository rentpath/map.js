define [], () ->

  return {
    assetURL: () ->
      $('meta[name="asset_host"]').attr('content')

    hideSpinner: () ->
      $('.spinner').hide()
  }