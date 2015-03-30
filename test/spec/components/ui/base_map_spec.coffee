define [
  'map/components/ui/base_map'
],
(
  BaseMap
) ->
  beforeEach ->
    @subject = new BaseMap document

  describe "#defineGoogleMapOptions", ->
    it "should build a hash", ->
      expect(@subject.defineGoogleMapOptions()).toEqual
        center:       new google.maps.LatLng(@subject.attr.latitude, @subject.attr.longitude)
        zoom:         12
        mapTypeId:    google.maps.MapTypeId.ROADMAP
        scaleControl: true
        draggable:    undefined

    it "should pass along gMapOptions", ->
      @subject = new BaseMap document,
        gMapOptions:
          panControl: false

      expect(@subject.defineGoogleMapOptions()).toEqual
        center:       new google.maps.LatLng(@subject.attr.latitude, @subject.attr.longitude)
        zoom:         12
        mapTypeId:    google.maps.MapTypeId.ROADMAP
        scaleControl: true
        panControl:   false
