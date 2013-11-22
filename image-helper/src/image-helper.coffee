define ['jquery'], ($) ->

  serversMetaKey = "image_server_urls"
  servers = null
  currentServerIndex = -1

  notFoundPath = ""
  assetHostMetaKey = "asset_host"

  isInvalidURL = (images) ->
    return (typeof(images) == 'undefined' || images.length == 0)

  url = (images, w, h) ->
    return notFoundURL() if isInvalidURL(images)

    path = if ($.isArray(images)) then images[0].path else images

    if path[0] != '/'
      path = '/' + path

    url = pickServer()

    pathParts = path.split('?')
    path = pathParts[0]
    queryString = if pathParts.length > 1 then '?' + pathParts[1] else ''

    if path.substr(-1) != '/'
      path += '/'

    path += w   if w
    path += "-" if w || h
    path += h   if h

    url += path + queryString
    url

  _contentFromMeta = (metaTag) ->
    content = metaTag.attr('content')
    (content || "").split(',')

  pickServer = ->
    servers ?= _contentFromMeta($("meta[name=\"#{serversMetaKey}\"]"))
    currentServerIndex += 1
    servers[currentServerIndex % servers.length]

  assetURL = ->
    $("meta[name=\"#{assetHostMetaKey}\"]").attr('content')

  notFoundURL = ->
    "#{assetURL()}#{notFoundPath}"

  setNotFoundPath = (path) ->
    notFoundPath = path

  isInvalidURL:     isInvalidURL
  url:              url
  pickServer:       pickServer
  assetURL:         assetURL
  notFoundURL:      notFoundURL
  setNotFoundPath:  setNotFoundPath
  servers:          servers
  _contentFromMeta: _contentFromMeta
