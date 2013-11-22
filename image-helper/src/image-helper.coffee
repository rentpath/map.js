define ['jquery', 'underscore'], ($, _) ->

  imageServerCount = 2
  nextImageServer = 0

  isInvalidURL = (photoList) ->
    return (typeof(photoList) == 'undefined' || photoList.length == 0)

  url = (photoList, w, h) ->
    if isInvalidURL(photoList)
      return notFoundURL()

    path = if ($.isArray(photoList)) then _.first(photoList).path else photoList

    if path[0] != '/'
      path = '/' + path

    url = "http://image" + pickImageServer() + ".apartmentguide.com"

    pathParts = path.split('?')
    path = pathParts[0]
    queryString = if pathParts.length > 1 then '?' + pathParts[1] else ''

    if path.substr(-1) != '/'
      path += '/'

    if w || h
      path += w if w
      path += "-"
      path += h if h

    url += path + queryString

    url

  pickImageServer = ->
    nextImageServer += 1
    if nextImageServer >= imageServerCount
      nextImageServer = 0

    if (nextImageServer) then nextImageServer else ''

  assetURL = ->
    $('meta[name="asset_host"]').attr('content')

  notFoundURL = ->
    assetURL() + "/images/prop_no_photo_results.png"

  assetURL:        assetURL
  isInvalidURL:    isInvalidURL
  url:             url
  pickImageServer: pickImageServer
  notFoundURL:     notFoundURL
