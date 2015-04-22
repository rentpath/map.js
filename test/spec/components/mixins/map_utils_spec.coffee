define [ ], () ->

  describeMixin 'map/components/mixins/map_utils', ->
    beforeEach ->
      @setupComponent()

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe '#limitScaleOf', ->
      it "should return a number with default precision of 4", ->
        expect(@component.limitScaleOf(99.12341)).toEqual('99.1234')

      it "should return a number with the requested precision", ->
        expect(@component.limitScaleOf(99.123451, 5)).toEqual('99.12345')

    describe 'fixture tests', ->
      beforeEach ->
        fixture = readFixtures('map_utils.html')
        @setupComponent(fixture)

      describe '#assetUrl', ->
        it "should return the meta tag content value", ->
          expect(@component.assetURL()).toEqual('http://localhost')

      describe '#getRefinements', ->
        it "should return the meta tag content value", ->
          expect(@component.getRefinements()).toEqual('beds')

      describe '#hideSpinner', ->
        it "should hide all spinners in the page", ->
          expect($('.spinner:visible').length).toEqual(2)
          @component.hideSpinner()
          expect($('.spinner:visible').length).toBe(0)

    describe 'defaults', ->

      describe '#assetUrl', ->
        it "should return the assetUrl baset url", ->
          fixture = readFixtures('map_utils.html')
          @setupComponent(fixture, {assetUrl: 'http://assets.localhost'})
          expect(@component.assetURL()).toEqual('http://assets.localhost')

