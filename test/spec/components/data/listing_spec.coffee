define [], () ->

  describeComponent 'map/components/data/listings', ->

    it 'should be defined', ->
      expect(@component).toBeDefined()

    describe 'default attributes with preset values', ->
      config = {}
      beforeEach ->
        @setupComponent('')
        config = @component.mapConfig()

      it 'should return whether or not it executes only once', ->
        expect(config.executeOnce).toBe(false)

      it 'should return the hybrid search route', ->
        expect(config.hybridSearchRoute).toEqual('/map_view/listings')

      it 'should return the map pins route', ->
        expect(config.mapPinsRoute).toEqual('/map/pins.json')

      it 'should return the hostname', ->
        expect(config.hostname).toEqual('www.apartmentguide.com')

      it 'should return the price range refinements', ->
        expect(config.priceRangeRefinements).toEqual({})

      it 'should return the valid possible refinements', ->
        expect(config.possibleRefinements).toEqual([ 'min_price', 'max_price' ])

    describe 'with override values', ->
      config = {}
      beforeEach ->
        @setupComponent('',
          {
            executeOnce: true
            hybridSearchRoute: "/test/map_view/listings"
            mapPinsRoute:  "/test/pins.json"
            hostname: '/foo'
            priceRangeRefinements: {}
            possibleRefinements: [ 'foo' ]
          })
        config = @component.mapConfig()

      it 'should return whether or not it executes only once', ->
        expect(config.executeOnce).toBe(true)

      it 'should return the hybrid search route', ->
        expect(config.hybridSearchRoute).toEqual('/test/map_view/listings')

      it 'should return the map pins route', ->
        expect(config.mapPinsRoute).toEqual('/test/pins.json')

      it 'should return the hostname', ->
        expect(config.hostname).toEqual('/foo')

      it 'should return the price range refinements', ->
        expect(config.priceRangeRefinements).toEqual({})

      it 'should return the valid possible refinements', ->
        expect(config.possibleRefinements).toEqual([ 'foo' ])
