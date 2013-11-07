describe "Login", ->
  login = null
  testWindow = null
  sampleEmail = "foo@example.com"

  resetTracker = ->
    tracker.path = backupTracker.path
    tracker.path_refinements = backupTracker.path_refinements

  beforeEach ->
    ready = false

    require ['../../login'], (Login) ->
      Login.init()
      login = Login.instance
      testWindow = $('<div></div>')
      ready = true

    waitsFor ->
      return ready

  describe "#_setEmail", ->

    it "assigns the zmail", ->
      login._setEmail(sampleEmail)
      expect(login.my.zmail).toEqual(sampleEmail)

    it "assigns the a cookie", ->
      login._setEmail(sampleEmail)
      expect($.cookie('zmail')).toEqual(sampleEmail)
