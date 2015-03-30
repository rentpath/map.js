'use strict'

#
# BEWARE: This is not full proof since agent strings can be masqueraded.
#  Depending on your need this may or may not work
#

define [ 'flight/lib/component' ], ( defineComponent ) ->

  mobileDetection = ->

    @isAndroid = () ->
      navigator.userAgent.match(/Android/i)

    @isBlackBerry = ->
      navigator.userAgent.match(/BlackBerry/i)

    @isIOS = ->
      navigator.userAgent.match(/iPhone|iPad|iPod/i)

    @isOpera = ->
      navigator.userAgent.match(/Opera Mini/i)

    @isWindows = ->
      navigator.userAgent.match(/IEMobile/i)

    @isMobile = ->
      @isAndroid() || @isBlackBerry() || @isIOS() || @isOpera() || @isWindows()

  return mobileDetection
