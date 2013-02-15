define ['jquery', './lib/browserdetect', 'jquery-cookie-rjs',], ($, browserdetect) ->
  class WH
    cacheBuster:  0
    domain:       ''
    firstVisit:   null
    lastLinkClicked: null
    metaData:     null
    oneTimeData:  null
    path:         ''
    performance:  window.performance || {}
    sessionID:    ''
    userID:       ''
    warehouseTag: null

    init: (opts={}) =>
      @clickBindSelector = opts.clickBindSelector || 'a, input[type=submit], input[type=button], img'
      if opts.exclusions?
        @clickBindSelector = @clickBindSelector.replace(/,\s+/g, ":not(#{opts.exclusions}), ")

      @domain            = document.location.host
      @exclusionList     = opts.exclusionList || []
      @fireCallback      = opts.fireCallback
      @parentTagsAllowed = opts.parentTagsAllowed || /div|ul/
      @path              = "#{document.location.pathname}#{document.location.search}"
      @warehouseURL      = opts.warehouseURL

      @setCookies()
      @determineDocumentDimensions(document)
      @determineWindowDimensions(window)
      @determinePlatform(window)

      @metaData = @getDataFromMetaTags(document)
      @firePageViewTag()
      @bindBodyClicked(document)

    bindBodyClicked: (doc) ->
      $(doc).on 'click', @clickBindSelector, @elemClicked

    determineParent: (elem) ->
      for el in elem.parents()
        return @firstClass($(el)) if el.tagName.toLowerCase().match(@parentTagsAllowed)

    determineWindowDimensions: (obj) ->
      obj = $(obj)
      @windowDimensions = "#{obj.width()}x#{obj.height()}"

    determineDocumentDimensions: (obj) ->
      obj = $(obj)
      @browserDimensions = "#{obj.width()}x#{obj.height()}"

    determinePlatform: ->
      WH.platform = browserdetect.platform()

    elemClicked: (e, opts={}) =>
      domTarget = e.target
      jQTarget = $(e.target)
      attrs = domTarget.attributes

      item = @firstClass(jQTarget) or ''
      subGroup = @determineParent(jQTarget) or ''
      value = jQTarget.text() or ''

      trackingData = {
        # cg, a.k.a. contentGroup, should come from meta tag with name "WH.cg"
        sg:     subGroup
        item:   item
        value:  value
        type:   'click'
        x:      e.clientX
        y:      e.clientY}

      for attr in attrs
        if attr.name.indexOf('data-') == 0 and attr.name not in WH.exclusionList
          realName = attr.name.replace('data-', '')
          trackingData[realName] = attr.value

      href = jQTarget.attr('href')
      if href and opts.followHref? and opts.followHref
        WH.lastLinkClicked = href
        e.preventDefault()

      @fire trackingData
      e.stopPropagation()

    fire: (obj) =>
      obj.ft                      = @firedTime()
      obj.cb                      = @cacheBuster++
      obj.sess                    = "#{@userID}.#{@sessionID}"
      obj.fpc                     = @userID
      obj.site                    = @domain
      obj.path                    = @path
      obj.title                   = $('title').text()
      obj.bs                      = WH.windowDimensions
      obj.sr                      = WH.browserDimensions
      obj.os                      = WH.platform.OS
      obj.browser                 = WH.platform.browser
      obj.ver                     = WH.platform.version
      obj.ref                     = document.referrer
      obj.login                   = if $.cookie('sgn') then 1 else 0
      obj.person_id               = $.cookie('zid') if $.cookie('sgn')

      if @oneTimeData?
        for key of @oneTimeData
          obj[key] = @oneTimeData[key]

      if WH.firstVisit
        obj.firstVisit = WH.firstVisit
        WH.firstVisit = null

      WH.fireCallback?(obj)

      WH.obj2query($.extend(obj, WH.metaData), (query) ->
        requestURL = WH.warehouseURL + query
      @obj2query($.extend(obj, @metaData), (query) =>
        requestURL = @warehouseURL + query

        # handle IE url length limit
        if requestURL.length > 2048 and navigator.userAgent.indexOf('MSIE') >= 0
          requestURL = requestURL.substring(0,2043) + "&tu=1"

        if WH.warehouseTag
          WH.warehouseTag[0].src = requestURL
        else
          WH.warehouseTag = $('<img/>', {id:'PRMWarehouseTag', border:'0', width:'1', height:'1', src: requestURL })

        WH.warehouseTag.onload = $('body').trigger('WH_pixel_success_' + obj.type)
        WH.warehouseTag.onerror = $('body').trigger('WH_pixel_error_' + obj.type)

        if WH.lastLinkClicked
          lastLinkRedirect = (e) ->
            # ignore obtrusive JS in an href attribute
            document.location = WH.lastLinkClicked if WH.lastLinkClicked.indexOf('javascript:') == -1

          WH.warehouseTag.unbind('load').unbind('error').
            bind('load',  lastLinkRedirect).
            bind('error', lastLinkRedirect)

    firedTime: =>
      now =
        @performance.now        or
        @performance.webkitNow  or
        @performance.msNow      or
        @performance.oNow       or
        @performance.mozNow
      (now? and now.call(@performance)) || new Date().getTime()

    firePageViewTag: ->
      @fire { type: 'pageview' }

    firstClass: (elem) ->
      return unless klasses = elem.attr('class')
      klasses.split(' ')[0]

    getMetaAttr: (name) ->
      if name
        selector = 'meta[name="' + name + '"]'
        meta = $(selector)
        if meta[0]
          content = meta.attr('content')
          if content
            return content
          else
            return undefined

    getOneTimeData: ->
      @oneTimeData

    getDataFromMetaTags: ->
      retObj = { cg: '' }
      metas = $('meta')
      for metaTag in metas
        metaTag = $(metaTag)
        if metaTag.attr('name') and metaTag.attr('name').indexOf('WH.') is 0
          name = metaTag.attr('name').replace('WH.', '')
          retObj[name] = metaTag.attr('content')
      retObj

    obj2query: (obj, cb) =>
      rv = []
      for key of obj
        rv.push "&#{key}=#{encodeURIComponent(val)}" if obj.hasOwnProperty(key) and (val = obj[key])?
      cb(rv.join('').replace(/^&/,'?'))
      return

    setCookies: ->
      userID    = $.cookie('WHUserID')
      sessionID = $.cookie('WHSessionID')
      timestamp = new Date().getTime()

      unless userID
        userID = timestamp
        $.cookie('WHUserID', userID, { expires: 3650, path: '/' })

      unless sessionID
        sessionID = timestamp
        WH.firstVisit = timestamp
        $.cookie('WHSessionID', sessionID, { path: '/' })

      WH.sessionID = sessionID
      WH.userID = userID

  setOneTimeData: (obj) =>
    @oneTimeData ||= {}
    for key of obj
      @oneTimeData[key] = obj[key]
