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

    @defaultAttr = ->
      flight.utils.push(@defaults, properties, true) || (@defaults = properties)

    @initAttributes = (attrs = {}) ->
      attr = Object.create(attrs)
      attr[key] = this.defaults[key] for key in this.defaults when (!attrs.hasOwnProperty(key))
      this.attr = attr
            
  return withDefaultAttr
