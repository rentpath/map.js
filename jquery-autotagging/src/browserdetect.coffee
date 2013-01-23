define ->
  class BrowserDetect
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
        string: `navigator.userAgent`,
        subString: "Chrome",
        identity: "Chrome"
      },
      {
        string: `navigator.userAgent`,
        subString: "OmniWeb",
        versionSearch: "OmniWeb/",
        identity: "OmniWeb"
      },
      {
        string: `navigator.vendor`,
        subString: "Apple",
        identity: "Safari",
        versionSearch: "Version"
      },
      {
        prop: `window.opera`,
        identity: "Opera"
      },
      {
        string: `navigator.vendor`,
        subString: "iCab",
        identity: "iCab"
      },
      {
        string: `navigator.vendor`,
        subString: "KDE",
        identity: "Konqueror"
      },
      {
        string: `navigator.userAgent`,
        subString: "Firefox",
        identity: "Firefox"
      },
      {
        string: `navigator.vendor`,
        subString: "Camino",
        identity: "Camino"
      },
      {  # for newer Netscapes (6+)
        string: `navigator.userAgent`,
        subString: "Netscape",
        identity: "Netscape"
      },
      {
        string: `navigator.userAgent`,
        subString: "MSIE",
        identity: "Explorer",
        versionSearch: "MSIE"
      },
      {
        string: `navigator.userAgent`,
        subString: "Gecko",
        identity: "Mozilla",
        versionSearch: "rv"
      },
      {
        # for older Netscapes (4-)
        string: `navigator.userAgent`,
        subString: "Mozilla",
        identity: "Netscape",
        versionSearch: "Mozilla"
      }
    ]

    dataOS: [
      {
        string: `navigator.platform`,
        subString: "Win",
        identity: "Windows"
      },
      {
        string: `navigator.platform`,
        subString: "Mac",
        identity: "Mac"
      },
      {
         string: `navigator.userAgent`,
         subString: "iPhone",
         identity: "iPhone/iPod"
      },
      {
        string: `navigator.platform`
        subString: "Linux",
        identity: "Linux"
      }
    ]

  return(BrowserDetect)