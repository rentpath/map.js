define [
  'underscore'
], (
  _
) ->

  generateTooltip = -> # class ToolTip extends google.maps.OverlayView
    @constructor = ->
      @ToolTip = new google.maps.OverlayView

      @container = $("<div/>", class: "hood_info_window")

      @position = null
      @count = null
      @listener = undefined

      @offset =
        x: 20
        y: 20

    @destroy = ->
      @setMap(null)

    @onAdd = ->
      @container.appendTo @getPanes().floatPane

    @onRemove = ->
      @container.remove()

    # @draw = ->
      # probably still need to do something here.

    @setContent = (data) ->
      @container.html(_.template(@attr.infoTemplate, data))
      @ToolTip.setMap(@attr.gMap)


    @hide = ->
      @container.hide().empty()
      google.maps.event.removeListener(@listener)

    @show = ->
      @container.show()

    @onMouseMove = (latLng) ->
      px = @ToolTip.getProjection().fromLatLngToContainerPixel(latLng)
      @container.css
        left: px.x + @offset.x
        top: px.y + @offset.y

    @updatePosition = (position, overlay) ->
      @listener = google.maps.event.addListener overlay, "mousemove", (event) =>
        @onMouseMove(event.latLng, overlay)
        @show()

    @after 'initialize', ->
      @on document, 'neighborhoodsAvailable', @constructor

  return generateTooltip
