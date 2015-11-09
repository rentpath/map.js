define [ ], () ->

  describeMixin 'map/components/mixins/stored_markers', ->
    beforeEach ->
      @setupComponent()
      localStorage.removeItem(@component.attr.storageKey)

    describe 'storage key', ->
      it "has a default for the storage key", () ->
        expect(typeof(@component.attr.storageKey)).toBe("string")
        expect(@component.attr.storageKey).not.toBe(undefined)

    describe '#load', ->
      it "returns an empty object when localStorage is empty", () ->
        expect(@component.load()).toEqual({})

    describe '#recordMarkerClick', ->
      it "saves a given value", () ->
        @component.recordMarkerClick("1")
        data = JSON.parse(localStorage.getItem(@component.attr.storageKey))

        expect(data["1"]).toBeDefined()

    describe "#storedMarkerExists", ->
      it "returns true for a value that has been stored", () ->
        @component.recordMarkerClick("1")
        expect(@component.storedMarkerExists("1")).toBeTruthy()

      it "returns false for a value that has not been stored", () ->
        expect(@component.storedMarkerExists("1")).toBeFalsy()
