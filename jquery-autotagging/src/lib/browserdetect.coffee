define ->
  class BrowserDetect
    @platform: ->
<<<<<<< HEAD
      os             = BrowserDetect.searchString(BrowserDetect.dataOS()) or "an unknown OS"

=======
      os             = BrowserDetect.searchString(BrowserDetect.dataOS()) or "An unknown OS"
>>>>>>> mss-jquery-autotagging
      result         = BrowserDetect.searchString(BrowserDetect.dataBrowser())
      browserName    = result.identity or "An unknown browser"
      versionLabel   = result.version

      browserVersion = BrowserDetect.searchVersion(versionLabel, navigator.userAgent) or
        BrowserDetect.searchVersion(versionLabel, navigator.appVersion) or
          "an unknown version"

      return {browser: browserName, version: browserVersion, OS: os.identity}

    @searchString: (data) ->
      for datum in data
        dataString = if (typeof datum.string == 'undefined') then null else datum.string
<<<<<<< HEAD
        dataProp = if (typeof datum.prop == 'undefined') then null else datum.prop
=======
        dataProp   = if (typeof datum.prop == 'undefined') then null else datum.prop
>>>>>>> mss-jquery-autotagging

        if dataString
          if dataString.indexOf(datum.subString) != -1
            return {identity: datum.identity, version: datum.versionSearch or datum.identity}
        else if dataProp
          return {identity: datum.identity, version: datum.versionSearch or datum.identity}

      return {identity: '', version: ''}

    @searchVersion: (versionLabel, dataString) ->
      index = dataString.indexOf(versionLabel)
      return if index == -1
      return parseFloat(dataString.substring(index + versionLabel.length + 1))

    @dataBrowser: (data) ->
      data || [
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
        {
          # for older Netscapes (4-)
          string: navigator.userAgent,
          subString: "Mozilla",
          identity: "Netscape",
          versionSearch: "Mozilla"
        }
      ]

    @dataOS: (data) ->
      data || [
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
          string: navigator.platform
          subString: "Linux",
          identity: "Linux"
        }
      ]
