define ['jquery'], ($) ->

  describeComponent 'map/components/data/info_window', ->

    beforeEach ->
      @setupComponent(refinements: 'refinements=foo_bar_baz-1')
      @listingId = 1111
      @ev = {}
      @data =
        listingId: @listingId

    it 'should be defined', ->
      expect(@component).toBeDefined()

    describe '#getData', ->
      it 'creates a url', ->
        xhrSpy = spyOn($, 'ajax')
        expectedUrl = "#{@component.attr.route}#{@listingId}?refinements=foo_bar_baz-1"
        @component.getData(@ev, @data)
        expect(xhrSpy.calls.mostRecent().args[0]['url']).toEqual expectedUrl

      it 'triggers an event on success', ->
        spyOn($, 'ajax').and.callFake( (params) -> params.success {foo:'bar'} )
        spyOnEvent document, 'infoWindowDataAvailable'
        @component.getData(@ev, @data)
        expect('infoWindowDataAvailable').toHaveBeenTriggeredOnAndWith(document, foo:'bar')
