define [], () ->

  describeComponent 'map/components/ui/base_map', ->
    describe 'non-fixture testing', ->
      beforeEach ->
        @setupComponent()

      it "should be defined", ->
        expect(@component).toBeDefined()

      describe "with override attr values", ->
        beforeEach ->
          @setupComponent
            latitude: 25.666
            longitude: 30.333
            gMapEvents:
              'center_changed': true
              'zoom_changed': true
            infoWindowOpen: true
            draggable: false
            geoData: { foo: "bar"}
            gMapOptions:
              draggable: true
            pinControlsSelector: "thunderdome"
            pinControlsCloseIconSelector: "thunderdome close"

        it "should return the overridden latitude", ->
          expect(@component.attr.latitude).toBe(25.666)

        it "should return the overridden longitude", ->
          expect(@component.attr.longitude).toBe(30.333)

        it "should return the overridden gMapEvents", ->
          expect(@component.attr.gMapEvents.center_changed).toBe(true)
          expect(@component.attr.gMapEvents.zoom_changed).toBe(true)

        it "should return the overridden infoWindowOpen", ->
          expect(@component.attr.infoWindowOpen).toBe(true)

        it "should return the overridden draggable", ->
          expect(@component.attr.draggable).toBe(false)

        it "should return the overridden geoData", ->
          expect(@component.attr.geoData["foo"]).toBe("bar")

        it "should return the overridden gMapOptions", ->
          expect(@component.attr.gMapOptions.draggable).toBe(true)

        it "should return the overridden pinControlsSelector", ->
          expect(@component.attr.pinControlsSelector).toBe("thunderdome")

        it "should return the overridden pinControlsCloseIconSelector", ->
          expect(@component.attr.pinControlsCloseIconSelector).toBe("thunderdome close")

      describe "#defineGoogleMapOptions", ->
        it "should build a hash", ->
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

      describe "#resetOurEventHash", ->
        beforeEach ->
          @setupComponent
            gMapEvents:
              'center_changed': true
              'zoom_changed': true

        it "should reset the map event hash", ->
          @component.resetOurEventHash()
          expect(@component.attr.gMapEvents.center_changed).toBe(false)
          expect(@component.attr.gMapEvents.zoom_changed).toBe(false)

      describe "#radiusToZoom", ->
        it "should return the correct radius when called with no value", ->
          expect(@component.radiusToZoom()).toBe(12)
        it "should return the correct radius based on value passed to it", ->
          expect(@component.radiusToZoom(5)).toBe(13)
