define [
  'jquery'
  'flight/lib/compose'
  'flight/lib/utils'
], (
  $
  compose
  flightUtils
) ->

  withDefaultAttr = ->

    @defaultAttrs = (properties) ->
      flightUtils.push(@defaults, properties, true) || (@defaults = properties)

    @initAttributes = (attrs = {}) ->
      attr = Object.create(attrs)
      attr[k] = v for k,v of this.defaults when (!attrs.hasOwnProperty(k))
      this.attr = attr

    # http://andrewdupont.net/2009/08/28/deep-extending-objects-in-javascript/
    @mergeAttributes = (destination, source) ->
      console.log "in mergeAttributes"
      for property of source
        console.log "  property: #{property}"
        if (source[property] && source[property].constructor && source[property].constructor == Object)
          destination[property] = destination[property] || {}
          console.log "    recurse: #{property}"
          arguments.callee(destination[property], source[property])
        else
          destination[property] = source[property]

  return withDefaultAttr
