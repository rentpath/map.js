define [], () ->

  describeComponent 'map/components/data/viewed_map_markers', ->

    it 'should be defined', ->
      expect(@component).toBeDefined()

    describe 'default attributes with preset values', ->
      beforeEach ->
        @setupComponent()

      describe 'activation flag', ->
        it 'should not record a listing id by default', ->
          expect(@component.storedMarkerExists("1")).toBeFalsy()
          data = { gMarker: { datum: { id: "1" } } }
          $(document).trigger('markerClicked', data)
          expect(@component.storedMarkerExists("1")).toBeFalsy()

        it 'should record a listing id when the flag is on', ->
          expect(@component.storedMarkerExists("1")).toBeFalsy()
          data = { gMarker: { saveMarkerClick: true, datum: { id: "1" } } }
          $(document).trigger('markerClicked', data)
          expect(@component.storedMarkerExists("1")).toBeTruthy()
