define [
  'jquery'
  'flight/lib/utils'
], (
  $
  flightUtils
) ->

  # This is used by non-flight modules so they can use flight mixins and the
  # familiar @attr pattern used by flight components.
  # It is particularly useful for setting up hierarchies of defaults that can
  # be overridden by a caller.

  withDefaultAttr = ->

    # This function gets run by flight at the point it is mixed in
    # via flight.compose() or defineComponent().
    #
    # Caller sets @attr to:
    #   map:
    #     canvasId: 'map_canvas'
    #     lat: 0
    #     lng: 0
    #
    # Caller mixes in a flight mixin with @defaultAttrs set to:
    #   spinnerSelector: '.spinner'
    #
    # This results in @attr being:
    #   map:
    #     canvasId: 'map_canvas'
    #     lat: 0
    #     lng: 0
    #   spinnerSelector: '.spinner'
    #

    @defaultAttrs = (properties, errorOnOverride = true) ->
      if @attr?
        flightUtils.push(@attr, properties, errorOnOverride)
      else
        @attr = properties

    # This function is used to override and add additional attributes to the default
    # attributes provided by mixins and any defaults the module itself has set.
    #
    # If @attr looks like it does at the end of the comments above and
    # the 'properties' argument looks like:
    #   map:
    #     canvasId: 'foo'
    #   totallyNewAttr: 'baz'
    #
    # The final result is @attr looking like:
    #   map:
    #     canvasId: 'foo'
    #     lat: 0
    #     lng: 0
    #   spinnerSelector: '.spinner'
    #   totallyNewAttr: 'baz'

    @overrideAttrsWith = (properties) ->
      @defaultAttrs(properties, false)

  return withDefaultAttr
