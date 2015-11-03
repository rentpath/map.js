# Converted from JS to Coffeescript by Sam B at RentPath.
# Animated Marker Movement. Robert Gerlach 2012-2013 https://github.com/combatwombat/marker-animate
# MIT license
#
# params:
# newPosition        - the new Position as google.maps.LatLng()
# options            - optional options object (optional)
# options.duration   - animation duration in ms (default 1000)
# options.easing     - easing function from jQuery and/or the jQuery easing plugin (default 'linear')
# options.complete   - callback function. Gets called, after the animation has finished
google.maps.Marker::animateTo = (newPosition, options) ->
  defaultOptions =
    duration: 1000
    easing: "linear"
    complete: null

  options = options or {}
  
  # complete missing options
  for key of defaultOptions
    options[key] = options[key] or defaultOptions[key]
  
  # throw exception if easing function doesn't exist
  unless options.easing is "linear"
    if typeof jQuery is "undefined" or not jQuery.easing[options.easing]
      throw "\"" + options.easing + "\" easing function doesn't exist. Include jQuery and/or the jQuery easing plugin and use the right function name."
      return

  window.requestAnimationFrame = window.requestAnimationFrame or window.mozRequestAnimationFrame or window.webkitRequestAnimationFrame or window.msRequestAnimationFrame
  window.cancelAnimationFrame = window.cancelAnimationFrame or window.mozCancelAnimationFrame
  
  # save current position. prefixed to avoid name collisions. separate for lat/lng to avoid calling lat()/lng() in every frame
  @AT_startPosition_lat = @getPosition().lat()
  @AT_startPosition_lng = @getPosition().lng()
  newPosition_lat = newPosition.lat()
  newPosition_lng = newPosition.lng()
  
  # crossing the 180° meridian and going the long way around the earth?
  if Math.abs(newPosition_lng - @AT_startPosition_lng) > 180
    if newPosition_lng > @AT_startPosition_lng
      newPosition_lng -= 360
    else
      newPosition_lng += 360
  animateStep = (marker, startTime) ->
    ellapsedTime = (new Date()).getTime() - startTime
    durationRatio = ellapsedTime / options.duration # 0 - 1
    easingDurationRatio = durationRatio
    
    # use jQuery easing if it's not linear
    easingDurationRatio = jQuery.easing[options.easing](durationRatio, ellapsedTime, 0, 1, options.duration)  if options.easing isnt "linear"
    if durationRatio < 1
      deltaPosition = new google.maps.LatLng(marker.AT_startPosition_lat + (newPosition_lat - marker.AT_startPosition_lat) * easingDurationRatio, marker.AT_startPosition_lng + (newPosition_lng - marker.AT_startPosition_lng) * easingDurationRatio)
      marker.setPosition deltaPosition
      
      # use requestAnimationFrame if it exists on this browser. If not, use setTimeout with ~60 fps
      if window.requestAnimationFrame
        marker.AT_animationHandler = window.requestAnimationFrame(->
          animateStep marker, startTime
          return
        )
      else
        marker.AT_animationHandler = setTimeout(->
          animateStep marker, startTime
          return
        , 17)
    else
      marker.setPosition newPosition
      options.complete()  if typeof options.complete is "function"
    return

  
  # stop possibly running animation
  if window.cancelAnimationFrame
    window.cancelAnimationFrame @AT_animationHandler
  else
    clearTimeout @AT_animationHandler
  animateStep this, (new Date()).getTime()
  return
