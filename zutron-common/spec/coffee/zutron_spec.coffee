describe "Zutron", ->

  zutron = undefined

  beforeEach ->
    ready = false

    require ['../../zutron-common', 'jasmine-jquery'], (_zutron) ->
      zutron = _zutron
      ready = true

    waitsFor ->
      return ready

  describe "zutron", ->

    it "is defined", ->
      expect(zutron).toBeDefined()
