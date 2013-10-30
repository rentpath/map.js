define ['jquery', './lib/browserdetect', 'jquery-cookie-rjs',], ($, browserdetect) ->
  class WH
    WH_SESSION_ID: 'WHSessionID'
    WH_LAST_ACCESS_TIME: 'WHLastAccessTime'
    WH_USER_ID: 'WHUserID'
    THIRTY_MINUTES_IN_MS: 30 * 60 * 1000
    TEN_YEARS_IN_DAYS: 3650
    cacheBuster:  0
    domain:       ''
    firstVisit:   null
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
      @opts              = opts

      @setFollowHref(opts)
      @setCookies()
      @determineDocumentDimensions(document)
      @determineWindowDimensions(window)
      @determinePlatform(window)

      @metaData = @getDataFromMetaTags(document)
      @firePageViewTag()
      @bindBodyClicked(document)

    bindBodyClicked: (doc) ->
      $(doc).on 'click', @clickBindSelector, @elemClicked

    clearOneTimeData: =>
      @oneTimeData = undefined

    determineParent: (elem) ->
      for el in elem.parents()
        return @firstClass($(el)) if el.tagName.toLowerCase().match(@parentTagsAllowed)

    determineWindowDimensions: (obj) ->
      obj = $(obj)
      @windowDimensions = "#{obj.width()}x#{obj.height()}"

    determineDocumentDimensions: (obj) ->
      obj = $(obj)
      @browserDimensions = "#{obj.width()}x#{obj.height()}"

    determinePlatform: (win) ->
      @platform = browserdetect.platform(win)

    determineReferrer: (doc, win) ->
      if win.location.href.match(/\?use_real_referrer\=true/)
        $.cookie('real_referrer')
      else
        doc.referrer

    elemClicked: (e, options={}) =>
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
        if attr.name.indexOf('data-') == 0 and attr.name not in @exclusionList
          realName = attr.name.replace('data-', '')
          trackingData[realName] = attr.value

      # Set again here to handle elemClicked re-bindings which
      # might pass a different followHref setting
      @setFollowHref(options)

      href = jQTarget.attr('href') || jQTarget.parent('a').attr('href')
      if href and @followHref
        @lastLinkClicked = href
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
      obj.bs                      = @windowDimensions
      obj.sr                      = @browserDimensions
      obj.os                      = @platform.OS
      obj.browser                 = @platform.browser
      obj.ver                     = @platform.version
      obj.ref                     = @determineReferrer(document, window)
      obj.registration            = if $.cookie('sgn') == '1' then 1 else 0
      obj.person_id               = $.cookie('zid') if $.cookie('sgn')?

      @fireCallback?(obj)

      if @oneTimeData?
        for key of @oneTimeData
          obj[key] = @oneTimeData[key]
        @clearOneTimeData();

      if @firstVisit
        obj.firstVisit = @firstVisit
        @firstVisit = null

      @obj2query($.extend(obj, @metaData), (query) =>
        requestURL = @warehouseURL + query

        # handle IE url length limit
        if requestURL.length > 2048 and navigator.userAgent.indexOf('MSIE') >= 0
          requestURL = requestURL.substring(0,2043) + "&tu=1"

        unless @warehouseTag
          @warehouseTag = $('<img/>',
            {id:'PRMWarehouseTag', border:'0', width:'1', height:'1' })

        @warehouseTag.onload = $('body').trigger('WH_pixel_success_' + obj.type)
        @warehouseTag.onerror = $('body').trigger('WH_pixel_error_' + obj.type)

        @warehouseTag[0].src = requestURL

        if @lastLinkClicked?
          lastLinkRedirect = (e) =>
            return unless @lastLinkClicked? && @lastLinkClicked.indexOf?
            # ignore obtrusive JS in an href attribute
            document.location = @lastLinkClicked if @lastLinkClicked.indexOf('javascript:') == -1

          @warehouseTag.unbind('load').unbind('error').
            bind('load',  lastLinkRedirect).
            bind('error', lastLinkRedirect))

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

    getDataFromMetaTags: (obj) ->
      retObj = { cg: '' }
      metas = $(obj).find('meta')

      for metaTag in metas
        metaTag = $(metaTag)
        if metaTag.attr('name') and metaTag.attr('name').indexOf('WH.') is 0
          name = metaTag.attr('name').replace('WH.', '')
          retObj[name] = metaTag.attr('content')
      retObj

    getOneTimeData: ->
      @oneTimeData

    # we are putting the tags ina predefined order before firing.  This will have
    # a performance hit - mocked in jsfiddle
    sort_order_array:  ["site" , "site_version","firstvisit","tu","cg","listingid","dpg","type"
                        ,"sg","item","value","ssSiteName","ssTestName","ssVariationGroupName"
                        ,"spg","lpp","path","logged_in","ft"]
    setTagOrder: (obj) ->
      prop_key_array = []
      result_array = []

      for key of obj
        prop_key_array.push key

      for elem of @sort_order_array
        index = prop_key_array.indexOf(@sort_order_array[elem])
        if index > 0
          result_array.push prop_key_array[index]
          prop_key_array.splice(index,1)

      result_array = result_array.concat(prop_key_array)

      return result_array

    obj2query: (obj, cb) =>
      tag_order = @setTagOrder(obj)
      rv = []
      for elem of tag_order
        key = tag_order[elem]
        rv.push "&#{key}=#{encodeURIComponent(val)}" if obj.hasOwnProperty(key) and (val = obj[key])?
      cb(rv.join('').replace(/^&/,'?'))
      return

    getSessionID: (currentTime) ->
      last_access_time = $.cookie(@WH_LAST_ACCESS_TIME) or currentTime
      if $.cookie(@WH_SESSION_ID) == null
        @firstVisit = currentTime
        return currentTime
      else
        return $.cookie(@WH_SESSION_ID)
    
    setCookies: ->
      userID    = $.cookie(@WH_USER_ID)
      timestamp = (new Date()).getTime()

      unless userID
        userID = timestamp
        $.cookie(@WH_USER_ID, userID, { expires: @TEN_YEARS_IN_DAYS, path: '/' })

      sessionID = @getSessionID(timestamp)
      
      $.cookie(@WH_SESSION_ID, sessionID, { path: '/' })
      $.cookie(@WH_LAST_ACCESS_TIME, timestamp, { path: '/' })

      @sessionID = sessionID
      @userID = userID

    setOneTimeData: (obj) ->
      @oneTimeData ||= {}
      for key of obj
        @oneTimeData[key] = obj[key]

    setFollowHref: (opts={}) ->
      @lastLinkClicked = null
      @followHref = if opts.followHref? then opts.followHref else true
