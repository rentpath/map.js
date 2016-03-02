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

    describe '#queryData', ->
      beforeEach ->
        @setupComponent('')

      it 'includes lat/lng data when given', ->
        data = @component.queryData
          latitude: 1
          longitude: 2
          lat1: 3
          lng1: 4
          lat2: 5
          lng2: 6

        expect(data.lat).toBe 1
        expect(data.latitude).toBe 1

        expect(data.lng).toBe 2
        expect(data.longitude).toBe 2

        expect(data.lat1).toBe 3
        expect(data.lng1).toBe 4

        expect(data.lat2).toBe 5
        expect(data.lng2).toBe 6

      it 'does not include lat/lng data when missing', ->
        data = @component.queryData({})

        expect(data.hasOwnProperty('lat')).toEqual false
        expect(data.hasOwnProperty('latitude')).toEqual false

        expect(data.hasOwnProperty('lng')).toEqual false
        expect(data.hasOwnProperty('longitude')).toEqual false

        expect(data.hasOwnProperty('lat1')).toEqual false
        expect(data.hasOwnProperty('lng2')).toEqual false

        expect(data.hasOwnProperty('lat2')).toEqual false
        expect(data.hasOwnProperty('lng2')).toEqual false
