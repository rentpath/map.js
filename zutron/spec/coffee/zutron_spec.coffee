describe "Zutron", ->
  zutron = undefined
  JJQuery = undefined

  beforeEach ->
    ready = false
    jasmine.getGlobal().zutron_host = "http://test.com"

    require ['../../zutron', 'jasmine-jquery'], (_zutron, $) ->
      zutron = _zutron
      ready = true
      JJQuery = $

    waitsFor ->
      return ready

  describe '#displayErrorMessage', ->
    it "should pickup configuration object", ->
      setFixtures(sandbox({id: 'test_error_div'}))
      zutronConfig =
        host: 'ag'
        error_div: '#test_error_div'
      zutron.init(zutronConfig)
      zutron.displayErrorMessage('test error message')
      expect($('#test_error_div').text()).toEqual('test error message')

  describe "functionality", ->
    it "is defined", ->
      expect(zutron).toBeDefined()

    it "should get data for zid", ->
      spyOn($,"ajax").andCallFake (req) ->
        d = $.Deferred()
        d.resolve
          zid:
            key: "asdf"
            listings: []
        return d.promise()

      zutron.getSavedListings()
      $.fn.on "zutron/savedListings", (data)->
        expect(data).toBeDefined()

