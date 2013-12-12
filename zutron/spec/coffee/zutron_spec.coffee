describe "Zutron", ->

  zutron = undefined

  beforeEach ->
    ready = false
    jasmine.getGlobal().zutron_host = "http://test.com"

    require ['../../zutron', 'jasmine-jquery'], (_zutron, $) ->
      zutron = _zutron
      ready = true

    waitsFor ->
      return ready

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

    # it "should test the stuff that needs testing", ->

