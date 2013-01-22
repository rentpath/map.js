window.WH = {
  lastLinkClicked: null, warehouseTag: null, firstVisit: null
  path: '', domain: '', sessionID: '', userID: ''
  cacheBuster: 0

  init: (opts={}) ->
    WH.clickBindSelector = opts.clickBindSelector or 'a, input[type=submit], input[type=button], img'
    WH.warehouseURL      = opts.warehouseURL      or 'http://my-data-warehouse.com/tracker.gif'
    WH.parentTagsAllowed = opts.parentTagsAllowed or /div|ul/

    WH.clickBindSelector = WH.clickBindSelector.replace(/,\s+/g, ":not(#{opts.exclusions}), ") if opts.exclusions?

    WH.setCookies()
    WH.determinePlatform()
    WH.determineDimensions()
    WH.path = "#{document.location.pathname}#{document.location.search}"
    WH.domain = document.location.host
    WH.exclusionList = opts.exclusionList || []

    $ ->
      WH.metaData = WH.getDataFromMetaTags()
      WH.firePageViewTag()
      WH.bindBodyClicked()

  firePageViewTag: ->
    WH.fire { type: 'pageview' }

  firstClass: (elem) ->
    return unless klasses = elem.attr('class')
    klasses.split(' ')[0]

  determineParent: (elem) ->
    for el in elem.parents()
      return WH.firstClass($(el)) if el.tagName.toLowerCase().match(WH.parentTagsAllowed)

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

  bindBodyClicked: -> $(document).on 'click', WH.clickBindSelector, WH.elemClicked

  determineDimensions: ->
    win = $(window)
    doc = $(document)
    WH.windowDimensions = "#{win.width()}x#{win.height()}"
    WH.browserDimensions = "#{doc.width()}x#{doc.height()}"

  determinePlatform: ->
    WH.platform = WH.BrowserDetect.init()

  elemClicked: (e, opts={}) ->
    domTarget = e.target
    jQTarget = $(e.target)
    attrs = domTarget.attributes

    item = WH.firstClass(jQTarget) or ''
    subGroup = WH.determineParent(jQTarget) or ''
    value = jQTarget.text() or ''

    trackingData = {
      # cg, a.k.a. contentGroup, should come from meta tag with name "WH.cg"
      sg: subGroup
      item: item
      value: value
      type: 'click'
      x: e.clientX
      y: e.clientY
    }

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

  fire: (obj) ->
    obj.cb = WH.cacheBuster++
    obj.sess = "#{WH.userID}.#{WH.sessionID}"
    obj.fpc = WH.userID
    obj.site =  WH.domain
    obj.path = WH.path
    obj.title = $('title').text()
    obj.bs = WH.windowDimensions
    obj.sr = WH.browserDimensions
    obj.os = WH.platform.OS
    obj.browser = WH.platform.browser
    obj.ver = WH.platform.version
    obj.ref = document.referrer

    if WH.firstVisit
      obj.firstVisit = WH.firstVisit
      WH.firstVisit = null
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
          bind('error', lastLinkRedirect)

    )
    return

  obj2query: (obj, cb) ->
    rv = []
    for key of obj
      rv.push "&#{key}=#{encodeURIComponent(val)}" if obj.hasOwnProperty(key) and (val = obj[key])?
    cb(rv.join('').replace(/^&/,'?'))
    return

  setCookies: ->
    userID = $.cookie('WHUserID')
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

  BrowserDetect: {
    init: ->
      this.browser = this.searchString(this.dataBrowser) or "An unknown browser"
      this.version = this.searchVersion(navigator.userAgent) or this.searchVersion(navigator.appVersion) or "an unknown version"
      this.OS = this.searchString(this.dataOS) or "an unknown OS"
      this

    searchString: (data) ->
      _results = []
      for datum in data
        dataString = datum.string
        dataProp = datum.prop
        this.versionSearchString = datum.versionSearch or datum.identity
        if dataString
          if dataString.indexOf(datum.subString) != -1
            return datum.identity
        else if dataProp
          return datum.identity
      return _results

    searchVersion: (dataString) ->
      index = dataString.indexOf(this.versionSearchString)
      return if index == -1
      return parseFloat(dataString.substring(index+this.versionSearchString.length+1))

    dataBrowser: [
      {
        string: navigator.userAgent,
        subString: "Chrome",
        identity: "Chrome"
      },
      {
        string: navigator.userAgent,
        subString: "OmniWeb",
        versionSearch: "OmniWeb/",
        identity: "OmniWeb"
      },
      {
        string: navigator.vendor,
        subString: "Apple",
        identity: "Safari",
        versionSearch: "Version"
      },
      {
        prop: window.opera,
        identity: "Opera"
      },
      {
        string: navigator.vendor,
        subString: "iCab",
        identity: "iCab"
      },
      {
        string: navigator.vendor,
        subString: "KDE",
        identity: "Konqueror"
      },
      {
        string: navigator.userAgent,
        subString: "Firefox",
        identity: "Firefox"
      },
      {
        string: navigator.vendor,
        subString: "Camino",
        identity: "Camino"
      },
      {  # for newer Netscapes (6+)
        string: navigator.userAgent,
        subString: "Netscape",
        identity: "Netscape"
      },
      {
        string: navigator.userAgent,
        subString: "MSIE",
        identity: "Explorer",
        versionSearch: "MSIE"
      },
      {
        string: navigator.userAgent,
        subString: "Gecko",
        identity: "Mozilla",
        versionSearch: "rv"
      },
      {     # for older Netscapes (4-)
        string: navigator.userAgent,
        subString: "Mozilla",
        identity: "Netscape",
        versionSearch: "Mozilla"
      }
    ],
    dataOS : [
      {
        string: navigator.platform,
        subString: "Win",
        identity: "Windows"
      },
      {
        string: navigator.platform,
        subString: "Mac",
        identity: "Mac"
      },
      {
         string: navigator.userAgent,
         subString: "iPhone",
         identity: "iPhone/iPod"
      },
      {
        string: navigator.platform,
        subString: "Linux",
        identity: "Linux"
      }
    ]
  }
}
