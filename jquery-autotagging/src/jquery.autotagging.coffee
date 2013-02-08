define ['jquery', 'lib/browserdetect', 'jquery-cookie-rjs',], ($, browserdetect) ->
  class WH
    cacheBuster:  0
    domain:       ''
    firstVisit:   null
    lastLinkClicked: null
    path:         ''
    sessionID:    ''
    userID:       ''
    warehouseTag: null
    performance: window.performance || {}

    init: (opts={}) ->
      WH.clickBindSelector = opts.clickBindSelector
      WH.clickBindSelector = WH.clickBindSelector.
        replace(/,\s+/g, ":not(#{opts.exclusions}), ") if opts.exclusions?
      WH.domain            = document.location.host
      WH.exclusionList     = opts.exclusionList || []
      WH.fireCallback      = opts.fireCallback
      WH.parentTagsAllowed = opts.parentTagsAllowed or /div|ul/
      WH.path              = "#{document.location.pathname}#{document.location.search}"
      WH.warehouseURL      = opts.warehouseURL

      WH.setCookies()
      WH.determineDocumentDimensions(document)
      WH.determineWindowDimensions(window)
      WH.determinePlatform()

      $ ->
        WH.metaData = WH.getDataFromMetaTags()
        WH.firePageViewTag()
        WH.bindBodyClicked()

    bindBodyClicked: -> $(document).on 'click', WH.clickBindSelector, WH.elemClicked

    determineParent: (elem) ->
      for el in elem.parents()
        return WH.firstClass($(el)) if el.tagName.toLowerCase().match(WH.parentTagsAllowed)

    determineWindowDimensions: (obj) ->
      win = $(obj)
      WH.windowDimensions = "#{win.width()}x#{win.height()}"

    determineDocumentDimensions: (obj) ->
      doc = $(obj)
      WH.browserDimensions = "#{doc.width()}x#{doc.height()}"

    determinePlatform: ->
      WH.platform = browserdetect.platform()

    elemClicked: (e, opts={}) ->
      domTarget = e.target
      jQTarget = $(e.target)
      attrs = domTarget.attributes

      item = WH.firstClass(jQTarget) or ''
      subGroup = WH.determineParent(jQTarget) or ''
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

      WH.fire trackingData
      e.stopPropagation()

    firedTime: () ->
      return WH.performance.now()       ||
             WH.performance.mozNow()    ||
             WH.performance.msNow()     ||
             WH.performance.oNow()      ||
             WH.performance.webkitNow() ||
             new Date().getTime()

    fire: (obj) ->
      obj.ft                      = WH.firedTime()
      obj.cb                      = WH.cacheBuster++
      obj.sess                    = "#{WH.userID}.#{WH.sessionID}"
      obj.fpc                     = WH.userID
      obj.site                    = WH.domain
      obj.path                    = WH.path
      obj.title                   = $('title').text()
      obj.bs                      = WH.windowDimensions
      obj.sr                      = WH.browserDimensions
      obj.os                      = WH.platform.OS
      obj.browser                 = WH.platform.browser
      obj.ver                     = WH.platform.version
      obj.ref                     = document.referrer
      obj.registration            = $.cookie('sgn') ? 1 : 0
      obj.person_id               = $.cookie('zid')
      obj.email_registration      = ($.cookie('provider') == 'identity') ? 1 : 0
      obj.facebook_registration   = ($.cookie('provider') == 'facebook') ? 1 : 0
      obj.googleplus_registration = ($.cookie('provider') == 'google_oauth2') ? 1 : 0
      obj.twitter_registration    = ($.cookie('provider') == 'twitter') ? 1 :  0

      if WH.firstVisit
        obj.firstVisit = WH.firstVisit
        WH.firstVisit = null

      if WH.fireCallback
        WH.fireCallback(obj)

      WH.obj2query($.extend(obj, WH.metaData), (query) ->
        requestURL = WH.warehouseURL + query

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
            bind('error', lastLinkRedirect))

      return

    firePageViewTag: ->
      WH.fire { type: 'pageview' }

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

    getDataFromMetaTags: ->
      retObj = { cg: '' }
      metas = $('meta')
      for metaTag in metas
        metaTag = $(metaTag)
        if metaTag.attr('name') and metaTag.attr('name').indexOf('WH.') is 0
          name = metaTag.attr('name').replace('WH.', '')
          retObj[name] = metaTag.attr('content')
      retObj

    obj2query: (obj, cb) ->
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


