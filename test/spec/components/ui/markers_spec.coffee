define [], () ->
  describeComponent 'map/components/ui/markers', ->
    beforeEach ->
      @setupComponent()

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe "with override values", ->
      beforeEach ->
        @setupComponent
          searchGeoData: { foo: "bar" }
          listingCountSelector: '#override_selector'
          listingCountText: "Override Text: "
          markers: ["marker1"]
          markersIndex: { 1: "marker1"}
          markerOptions:
            fitBounds: true

      it "should return the overridden listingCountSelector", ->
        expect(@component.attr.listingCountSelector).toBe('#override_selector')

      it "should return the overridden listingCountText", ->
        expect(@component.attr.listingCountText).toBe('Override Text: ')

      it "should return the overridden searchGeoData", ->
        expect(@component.attr.searchGeoData["foo"]).toBe("bar")

      it "should return the overriden markers", ->
        expect(@component.attr.markers[0]).toBe("marker1")

      it "should return the overriden markersIndex", ->
        expect(@component.attr.markersIndex["1"]).toBe("marker1")

      it "should return the overriden markerOptions", ->
        expect(@component.attr.markerOptions.fitBounds).toBe(true)

    describe "#iconBasedOnType", ->
      describe "with arg mapPin", ->
        describe "when given a function", ->
          beforeEach ->
            @setupComponent
              mapPin: (datum) ->
                { url: "/url/to/pin/from/func" }

          it "uses the return value from the function", ->
            expect(@component.iconBasedOnType(@component.attr.mapPin, {})).toEqual({ url: "/url/to/pin/from/func" })

        describe "when given a url", ->
          beforeEach ->
            @setupComponent
              mapPin: "/url/to/pin"
              mapPinFree: "/url/to/free/pin"

          it "uses mapPin when not free", ->
            expect(@component.iconBasedOnType(@component.attr.mapPin, {})).toEqual({ url: "/url/to/pin" })

          it "uses mapPinFree when free", ->
            expect(@component.iconBasedOnType(@component.attr.mapPin, { free: true })).toEqual({ url: "/url/to/free/pin" })

      describe "with arg mapPinShadow", ->
        describe "when given a function", ->
          beforeEach ->
            @setupComponent
              mapPinShadow: (datum) ->
                { url: "/url/to/pin/from/func" }

          it "uses the return value from the function", ->
            expect(@component.iconBasedOnType(@component.attr.mapPinShadow, {})).toEqual({ url: "/url/to/pin/from/func" })

        describe "when given a url", ->
          beforeEach ->
            @setupComponent
              mapPinShadow: "/url/to/pin"

          it "uses mapPinShadow when not free", ->
            expect(@component.iconBasedOnType(@component.attr.mapPinShadow, {})).toEqual({ url: "/url/to/pin"})

          it "is blank when free", ->
            expect(@component.iconBasedOnType(@component.attr.mapPinShadow, { free: true })).toEqual({ url: "" })

    describe "#updateCluster", ->
      describe "when attr.shouldCluster is true", ->
        beforeEach ->
          @setupComponent
            shouldCluster: (markers) ->
              true

        it "should init markerClusterer", ->
          @component.updateCluster([])
          expect(@component.attr.markerClusterer).toBeDefined()

      describe "when attr.shouldCluster is false", ->
        beforeEach ->
          @setupComponent
            shouldCluster: (markers) ->
              false

        it "should not init markerClusterer", ->
          @component.updateCluster([])
          expect(@component.attr.markerClusterer).not.toBeDefined()
