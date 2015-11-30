define [], () ->
  describeComponent 'map/components/ui/markers', ->
    datum =
      id: 1
      name: "Foo Bar"
      price: "$1,000"

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

        describe "when given an object", ->
          beforeEach ->
            @setupComponent
              mapPin: { foo: "/url/to/pin/from/func" }

          it "uses the return value from the function", ->
            expect(@component.iconBasedOnType(@component.attr.mapPin, {})).toEqual({ foo: "/url/to/pin/from/func" })

        describe "when given a url", ->
          beforeEach ->
            @setupComponent
              mapPin: "/url/to/pin"

          it "uses mapPin", ->
            expect(@component.iconBasedOnType(@component.attr.mapPin, {})).toEqual("/url/to/pin")

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

          it "uses mapPinShadow", ->
            expect(@component.iconBasedOnType(@component.attr.mapPinShadow, {})).toEqual("/url/to/pin")

    describe '#createMarker', ->
      describe 'without label options', ->
        beforeEach ->
          @setupComponent()
          @marker = @component.createMarker(datum)

        it 'is a standard marker type', ->
          expect(@marker.constructor).toEqual google.maps.Marker

      describe 'with label options', ->
        beforeEach ->
          @setupComponent
            markerLabelOptions: (datum) ->
              content: datum.price
          @marker = @component.createMarker(datum)

        it 'is a marker with label type', ->
          expect(@marker.constructor).toEqual @component.attr.MarkerWithLabel

    describe '#markerOptions', ->
      describe 'without label options', ->
        beforeEach ->
          @setupComponent()
          @options = @component.markerOptions(datum)

        it 'builds a list of options', ->
          expect(@options.datum).toEqual datum
          expect(@options.title).toEqual datum.name

        it 'does not have a label', ->
          expect(@options.labelContent).toEqual(undefined)

      describe 'with label options', ->
        beforeEach ->
          @setupComponent
            markerLabelOptions: (datum) ->
              content: datum.price
              cssClass: 'marker-label'
              anchor:
                x: 1
                y: 2
          @options = @component.markerOptions(datum)

        it 'assigns label content and class', ->
          expect(@options.labelContent).toEqual '$1,000'
          expect(@options.labelClass).toEqual 'marker-label'

        it 'builds an anchor', ->
          expect(@options.labelAnchor.x).toEqual 1
          expect(@options.labelAnchor.y).toEqual 2

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

    describe '#markerAnimation', ->
      beforeEach ->
        @setupComponent()
        @marker = jasmine.createSpyObj('marker', ['setAnimation'])
        @component.attr.markersIndex['1234567'] = @marker

      it 'animates the marker', ->
        @component.markerAnimation undefined, id: "result_1234567", animation: 'bounce'
        expect(@marker.setAnimation).toHaveBeenCalledWith('bounce')
