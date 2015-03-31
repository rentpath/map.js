define [ ], ( ) ->

  describeComponent 'map/components/ui/base_map', ->
    describe "#defineGoogleMapOptions", ->
      it "should build a hash", ->
        @setupComponent()

        expect(@component.defineGoogleMapOptions()).toEqual
          center:       new google.maps.LatLng(@component.attr.latitude, @component.attr.longitude)
          zoom:         12
          mapTypeId:    google.maps.MapTypeId.ROADMAP
          scaleControl: true
          draggable:    undefined

      it "should pass along gMapOptions", ->
        @setupComponent
          gMapOptions:
            panControl: false

        expect(@component.defineGoogleMapOptions()).toEqual
          center:       new google.maps.LatLng(@component.attr.latitude, @component.attr.longitude)
          zoom:         12
          mapTypeId:    google.maps.MapTypeId.ROADMAP
          scaleControl: true
          panControl:   false
