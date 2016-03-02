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
          expect(@component.defineGoogleMapOptions()).toEqual(
            jasmine.objectContaining
              zoom:         12
              mapTypeId:    google.maps.MapTypeId.ROADMAP
              scaleControl: true
              draggable:    undefined
          )

        it "should pass along gMapOptions", ->
          @setupComponent
            gMapOptions:
              panControl: false

          expect(@component.defineGoogleMapOptions()).toEqual(
            jasmine.objectContaining
              zoom:         12
              mapTypeId:    google.maps.MapTypeId.ROADMAP
              scaleControl: true
              panControl:   false
          )

      describe "#resetOurEventHash", ->
        beforeEach ->
          @setupComponent
            gMapEvents:
              'center_changed': true
              'zoom_changed': true
              'max_bounds_changed': true

        it "should reset the map event hash", ->
          @component.resetOurEventHash()
          expect(@component.attr.gMapEvents.center_changed).toBe(false)
          expect(@component.attr.gMapEvents.zoom_changed).toBe(false)
          expect(@component.attr.gMapEvents.max_bounds_changed).toBe(false)

      describe "#checkForMaxBoundsChange", ->
        beforeEach ->
          swLat = 34.0
          swLng = -84.0
          neLat = 34.4
          neLng = -84.4
          @component.attr.maxBounds = new google.maps.LatLngBounds(
            new google.maps.LatLng(swLat, swLng)
            new google.maps.LatLng(neLat, neLng)
          )
          @containedBounds = new google.maps.LatLngBounds(
            new google.maps.LatLng(swLat + 0.1, swLng + 0.1)
            new google.maps.LatLng(neLat - 0.1, neLng - 0.1)
          )
          @uncontainedBounds = new google.maps.LatLngBounds(
            new google.maps.LatLng(swLat - 0.1, swLng - 0.1)
            new google.maps.LatLng(neLat + 0.1, neLng + 0.1)
          )

        describe "when current bounds contained by max bounds seen", ->
          it "should not turn on max_bounds_changed in event hash", ->
            spyOn(@component, "currentBounds").and.returnValue @containedBounds
            @component.checkForMaxBoundsChange()
            expect(@component.attr.gMapEvents.max_bounds_changed).toBe(false)

        describe "when current bounds not contained by max bounds seen", ->
          it "should turn on max_bounds_changed in event hash", ->
            spyOn(@component, "currentBounds").and.returnValue @uncontainedBounds
            @component.checkForMaxBoundsChange()
            expect(@component.attr.gMapEvents.max_bounds_changed).toBe(true)

      describe "#radiusToZoom", ->
        it "should return the correct radius when called with no value", ->
          expect(@component.radiusToZoom()).toBe(12)
        it "should return the correct radius based on value passed to it", ->
          expect(@component.radiusToZoom(5)).toBe(13)

      describe '#fireOurMapEvents', ->
        beforeEach ->
          spyOn @component, 'mapState'

        it 'triggers when max_bounds_changed', ->
          spyEvent = spyOnEvent(document, 'uiMapZoomForListings')
          @component.storeEvent 'max_bounds_changed'
          @component.fireOurMapEvents()
          expect(spyEvent.calls.length).toEqual 1

        it 'triggers when zoom_changed', ->
          spyEvent = spyOnEvent(document, 'uiMapZoom')
          @component.storeEvent 'zoom_changed'
          @component.fireOurMapEvents()
          expect(spyEvent.calls.length).toEqual 1

        it 'triggers when center_changed', ->
          spyEvent = spyOnEvent(document, 'uiMapCenter')
          @component.storeEvent 'center_changed'
          @component.fireOurMapEvents()
          expect(spyEvent.calls.length).toEqual 1

        it 'does not trigger uiMapCenter and uiMapZoomForListings together', ->
          zoomSpyEvent = spyOnEvent(document, 'uiMapZoomForListings')
          centerSpyEvent = spyOnEvent(document, 'uiMapCenter')
          @component.storeEvent 'max_bounds_changed'
          @component.storeEvent 'center_changed'
          @component.fireOurMapEvents()
          expect(zoomSpyEvent.calls.length).toEqual 1
          expect(centerSpyEvent.calls.length).toEqual 0

    describe '#mapState', ->
      latLngMock =
        lat: -> 0
        lng: -> 0

      gMapMock =
        getCenter: -> latLngMock
        getBounds: ->
          getNorthEast: -> latLngMock
          getSouthWest: -> latLngMock

      describe 'when user has not changed the map', ->
        beforeEach ->
          @setupComponent
            gMap: gMapMock

        it 'does not include a sort', ->
          expect(@component.mapState().sort).toEqual undefined

        it 'does not include lat/lng', ->
          expect(@component.mapState().hasOwnProperty('latitude')).toEqual false
          expect(@component.mapState().hasOwnProperty('longitude')).toEqual false
          expect(@component.mapState().hasOwnProperty('lat1')).toEqual false
          expect(@component.mapState().hasOwnProperty('lng1')).toEqual false
          expect(@component.mapState().hasOwnProperty('lat2')).toEqual false
          expect(@component.mapState().hasOwnProperty('lng2')).toEqual false

      describe 'when user has changed the map', ->
        beforeEach ->
          @setupComponent
            userChangedMap: true
            gMap: gMapMock

        it 'uses a distance based sort', ->
          expect(@component.mapState().sort).toEqual 'distance'

        it 'includes lat/lng', ->
          expect(@component.mapState().latitude).toEqual '0.0000'
          expect(@component.mapState().longitude).toEqual '0.0000'
          expect(@component.mapState().lat1).toEqual '0.0000'
          expect(@component.mapState().lng1).toEqual '0.0000'
          expect(@component.mapState().lat2).toEqual '0.0000'
          expect(@component.mapState().lng2).toEqual '0.0000'
