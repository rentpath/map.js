define ['jquery'], ($) ->

  describeComponent 'map/components/data/info_window', ->

    beforeEach ->
      @setupComponent(refinements:
                        '123xyz':
                          dim_name: '2-beds'
                          dim_id: '123xyz')
      @listingId = 1111
      @ev = {}
      @data =
        listingId: @listingId

    it 'should be defined', ->
      expect(@component).toBeDefined()

    describe '#queryParams', ->
      it 'creates a query string with beds', ->
        @setupComponent(refinements:
                          '1z141y8':
                            dim_name: '2-beds'
                            dim_id: '1z141y8')
        expect(@component.queryParams()).toEqual('?refinements=2-beds-1z141y8')

      it 'creates a query string with beds and baths', ->
        @setupComponent(refinements:
                          {
                            '1z141y8':
                                dim_name: '2-beds'
                                dim_id: '1z141y8'
                            '1z141y7':
                              dim_name: '2-baths'
                              dim_id: '1z141y7',
                          })
        expect(@component.queryParams()).toEqual('?refinements=2-beds-2-baths-1z141y8+1z141y7')

      it 'creates a query string with beds and price', ->
        @setupComponent(refinements:
                          '1z141y8':
                            dim_name: '2-beds'
                            dim_id: '1z141y8'
                          'max_price':
                            dim_name: 'max_price'
                            dim_id: 'max_price'
                            value: '1500')
        expect(@component.queryParams()).toEqual('?refinements=2-beds-1z141y8&max_price=1500')

      it 'creates a query string with price', ->
        @setupComponent(refinements:
                          'max_price':
                            dim_name: 'max_price'
                            dim_id: 'max_price'
                            value: '1500')
        expect(@component.queryParams()).toEqual('?max_price=1500')

      it 'creates a query string with propertyname', ->
        @setupComponent(refinements:
                          'propertyname':
                            dim_name: 'propertyname'
                            dim_id: 'propertyname'
                            value: 'amli')
        expect(@component.queryParams()).toEqual('?propertyname=amli')

      it 'returns an empty string when no refinements are present', ->
        @setupComponent(refinements: {})
        expect(@component.queryParams()).toEqual('')

    describe '#getData', ->
      it 'creates a url', ->
        xhrSpy = spyOn($, 'ajax')
        expectedUrl = "#{@component.attr.route}#{@listingId}?refinements=2-beds-123xyz"
        @component.getData(@ev, @data)
        expect(xhrSpy.calls.mostRecent().args[0]['url']).toEqual expectedUrl

      it 'triggers an event on success', ->
        spyOn($, 'ajax').and.callFake( (params) -> params.success {foo:'bar'} )
        spyOnEvent document, 'infoWindowDataAvailable'
        @component.getData(@ev, @data)
        expect('infoWindowDataAvailable').toHaveBeenTriggeredOnAndWith(document, foo:'bar')
