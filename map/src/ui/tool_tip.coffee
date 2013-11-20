define [], () ->

  class ToolTip extends google.maps.OverlayView
    constructor: (@map) ->
      @mapDiv = $("##{@map.getDiv().id}")

    container: $("<div/>",
      class: "hood_info_window"
    )
    listener: []
    offset:
      x: 20
      y: 20

    draw: ->
    destroy: ->
      @setMap(null)

    onAdd: ->
      @container.appendTo @getPanes().floatPane

    onRemove: ->
      @container.remove()

    setContent: (html) ->
      @container.html(html)
      @setMap(@map)

    updatePosition: (@overlay) ->
      google.maps.event.addListener @overlay, "mousemove", (event) =>
        @onMouseMove(event.latLng, overlay)
      @show()

    onMouseMove: (latLng) ->
      px = @getProjection().fromLatLngToContainerPixel(latLng)
      @container.css
        left: @getLeft(px)
        top: @getTop(px)

    hide: ->
      @container.hide().empty()
      google.maps.event.clearListeners @overlay, "mousemove"

    show: ->
      @container.show()

    getLeft: (position) ->
      pos = @mapWidth() - position.x - @container.outerWidth() - @offset.x
      if pos < 0
        @mapWidth() - @container.outerWidth() - @offset.x
      else
        position.x + @offset.x

    getTop: (position) ->
      pos = @mapHeight() - position.y - @container.outerHeight() - @offset.y
      if pos < 0
        @mapHeight() - @container.outerHeight() - (@offset.y * 2)
      else
        position.y - @container.outerHeight() - @offset.y

    mapWidth: ->
      @mapDiv.outerWidth()

    mapHeight: ->
      @mapDiv.outerHeight()




