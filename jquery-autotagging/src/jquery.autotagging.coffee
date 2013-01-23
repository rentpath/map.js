define ['jquery', 'lib/browserdetect'], ($, browserdetect) ->
  class WH
    cacheBuster:  0
    domain:       ''
    firstVisit:   null
    lastLinkClicked: null
    path:         ''
    sessionID:    ''
    userID:       ''
    warehouseTag: null

    init: (opts={}) ->
      @clickBindSelector = opts.clickBindSelector
      @clickBindSelector = @clickBindSelector.
        replace(/,\s+/g, ":not(#{opts.exclusions}), ") if opts.exclusions?
      @domain            = document.location.host
      @exclusionList     = opts.exclusionList || []
      @fireCallback      = opts.fireCallback
      @parentTagsAllowed = opts.parentTagsAllowed or /div|ul/
      @path              = "#{document.location.pathname}#{document.location.search}"
      @warehouseURL      = opts.warehouseURL

      setCookies()
      determineDocumentDimensions(document)
      determineWindowDimensions(window)
      determinePlatform()

      $ ->
        @metaData = getDataFromMetaTags(document)
        firePageViewTag()
        bindBodyClicked()

    bindBodyClicked (doc): -> $(doc).on 'click', @clickBindSelector, elemClicked

    determineParent: (elem) ->
      for el in elem.parents()
        return firstClass($(el)) if el.tagName.toLowerCase().match(@parentTagsAllowed)

    determineWindowDimensions: (obj) ->
      @windowDimensions = "#{obj.width()}x#{obj.height()}"

    determineDocumentDimensions: (obj) ->
      @browserDimensions = "#{obj.width()}x#{obj.height()}"

    determinePlatform: ->
      @platform = browserdetect.platform()

    elemClicked: (e, opts={}) ->
      domTarget = e.target
      jQTarget = $(e.target)
      attrs = domTarget.attributes

      item = firstClass(jQTarget) or ''
      subGroup = determineParent(jQTarget) or ''
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
        if attr.name.indexOf('data-') == 0 and attr.name not in @exclusionList
          realName = attr.name.replace('data-', '')
          trackingData[realName] = attr.value

      href = jQTarget.attr('href')
      if href and opts.followHref? and opts.followHref
        @lastLinkClicked = href
        e.preventDefault()

      fire trackingData
      e.stopPropagation()

    fire: (obj) ->
      obj.cb                      = @cacheBuster++
      obj.sess                    = "#{@userID}.#{@sessionID}"
      obj.fpc                     = @userID
      obj.site                    = @domain
      obj.path                    = @path
      obj.title                   = $('title').text()
      obj.bs                      = @windowDimensions
      obj.sr                      = @browserDimensions
      obj.os                      = @platform.OS
      obj.browser                 = @platform.browser
      obj.ver                     = @platform.version
      obj.ref                     = doc.referrer
      obj.registration            = $.cookie('sgn') ? 1 : 0
      obj.person_id               = $.cookie('zid')
      obj.email_registration      = ($.cookie('provider') == 'identity') ? 1 : 0
      obj.facebook_registration   = ($.cookie('provider') == 'facebook') ? 1 : 0
      obj.googleplus_registration = ($.cookie('provider') == 'google_oauth2') ? 1 : 0
      obj.twitter_registration    = ($.cookie('provider') == 'twitter') ? 1 :  0

      if @firstVisit
        obj.firstVisit = @firstVisit
        @firstVisit = null

      if @fireCallback
        @fireCallback(obj)

      obj2query($.extend(obj, @metaData), (query) ->
        requestURL = @warehouseURL + query

        # handle IE url length limit
        if requestURL.length > 2048 and navigator.userAgent.indexOf('MSIE') >= 0
          requestURL = requestURL.substring(0,2043) + "&tu=1"

        if @warehouseTag
          @warehouseTag[0].src = requestURL
        else
          @warehouseTag = $('<img/>',
            {id:'PRMWarehouseTag', border:'0', width:'1', height:'1', src: requestURL })

        @warehouseTag.onload = $('body').trigger('WH_pixel_success_' + obj.type)
        @warehouseTag.onerror = $('body').trigger('WH_pixel_error_' + obj.type)

        if @lastLinkClicked
          @lastLinkRedirect = (e) ->
            # ignore obtrusive JS in an href attribute
            document.location = @lastLinkClicked if @lastLinkClicked.indexOf('javascript:') == -1

          @warehouseTag.unbind('load').unbind('error').
            bind('load',  lastLinkRedirect).
            bind('error', lastLinkRedirect))

      return

    firePageViewTag: ->
      fire { type: 'pageview' }

    firstClass: (elem) ->
      return unless klasses = elem.attr('class')
      klasses.split(' ')[0]

    getDataFromMetaTags: (obj) ->
      retObj = { cg: '' }
      metas = $(obj).find('meta')

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

  return(WH)
