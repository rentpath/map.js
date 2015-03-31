'use strict'

#
# BEWARE: This is not full proof since agent strings can be masqueraded.
#  Depending on your need this may or may not work
#

define [ ], ( ) ->

  mobileDetection = ->

    @agent = 'Foo'

    @_isAndroid = ->
      @agent.match(/Android/i)

    @_isBlackBerry = ->
      @agent.match(/BlackBerry/i)

    @_isIOS = ->
      @agent.match(/iPhone|iPad|iPod/i)

    @_isOpera = ->
      @agent.match(/Opera Mini/i)

    @_isWindows = ->
      @agent.match(/IEMobile/i)

    @isMobile = (agent = navigator.userAgent) ->
      @agent = agent
      matches = @_isAndroid(agent) || @_isBlackBerry(agent) || @_isIOS(agent) || @_isOpera(agent) || @_isWindows(agent)
      (matches != null) && (matches.length > 0)

