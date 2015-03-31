define [ ], () ->

  describeMixin 'map/components/mixins/distance_conversion', ->
    beforeEach ->
      @setupComponent()

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe '#convertMilesToMeters', ->
      describe 'with bad input', ->
        it "should return zero when no arguments are passed", () ->
          expect(@component.convertMilesToMeters()).toBe(0)

        it "should return zero when undefined is passed", () ->
          expect(@component.convertMilesToMeters(undefined)).toBe(0)

        it "should return zero when an empty string is passed", () ->
          expect(@component.convertMilesToMeters('')).toBe(0)

      describe 'with valid input', ->
        it "should return meters when a miles value is passed", () ->
          result = Math.round(@component.convertMilesToMeters(1) * 100) / 100
          expect(result).toBe(1609.35)

    describe '#convertMetersToKilometers', ->
      describe 'with bad input', ->
        it "should return zero when no arguments are passed", () ->
          expect(@component.convertMilesToMeters()).toBe(0)

        it "should return zero when undefined is passed", () ->
          expect(@component.convertMilesToMeters(undefined)).toBe(0)

        it "should return zero when an empty string is passed", () ->
          expect(@component.convertMilesToMeters('')).toBe(0)

      describe 'with valid input', ->
        it "should return kilometers when a meters value is passed", () ->
          result = Math.round(@component.convertMetersToKilometers(2000) * 100) / 100
          expect(result).toBe(1.24)

    describe '#convertMetersToMiles', ->
      describe 'with bad input', ->
        it "should return zero when no arguments are passed", () ->
          expect(@component.convertMilesToMeters()).toBe(0)

        it "should return zero when undefined is passed", () ->
          expect(@component.convertMilesToMeters(undefined)).toBe(0)

        it "should return zero when an empty string is passed", () ->
          expect(@component.convertMilesToMeters('')).toBe(0)

      describe 'with valid input', ->
        it "should return miles when a meters value is passed", () ->
          result = Math.round(@component.convertMetersToMiles(10000) * 100) / 100
          expect(result).toBe(6.21)

