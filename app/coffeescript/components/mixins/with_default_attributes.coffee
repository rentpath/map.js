define [
  'jquery'
  'flight/lib/compose'
  'flight/lib/utils'
], (
  $
  compose
  mapUtils
) ->

  withDefaultAttr = ->

    @defaultAttrs = (properties) ->
      flight.utils.push(@defaults, properties, true) || (@defaults = properties)

    @initAttributes = (attrs = {}) ->
      attr = Object.create(attrs)
      attr[k] = v for k,v of this.defaults when (!attrs.hasOwnProperty(k))
      this.attr = attr

    return
    
  return withDefaultAttr
