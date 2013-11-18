define [], () ->

  class ToolTip extends google.maps.OverlayView
    constructor: (@map) ->

    container: $("<div/>",
      class: "hood_info_window"
    )
    listener: []
    offset:
      x: 20
      y: 20

    destroy: ->
      @setMap(null)

    onAdd: ->
      @container.appendTo @getPanes().floatPane

    onRemove: ->
      @container.remove()

    draw: ->

    setContent: (html) ->
      @container.html(html)
      @setMap(@map)

    hide: ->
      @container.hide().empty()
      google.maps.event.clearListeners @overlay, "mousemove"

    show: ->
      @container.show()

    onMouseMove: (latLng) ->
      px = @getProjection().fromLatLngToContainerPixel(latLng)
      @container.css
        left: px.x + @offset.x
        top: px.y + @offset.y

    updatePosition: (@overlay) ->

      google.maps.event.addListener @overlay, "mousemove", (event) =>
        @onMouseMove(event.latLng, overlay)
      @show()


