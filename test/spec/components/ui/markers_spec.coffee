define [ 'map/components/ui/markers' ], ( markers ) ->

  describeMixin 'map/components/ui/markers', ->
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
