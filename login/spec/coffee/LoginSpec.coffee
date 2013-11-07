describe "Login", ->
  login = null
  testWindow = null
  sampleEmail = "foo@example.com"
  newUser = "new"

  resetTracker = ->
    tracker.path = backupTracker.path
    tracker.path_refinements = backupTracker.path_refinements

  beforeEach ->
    ready = false

    require ['../../login', 'jasmine-jquery'], (Login) ->
      Login.init()
      login = Login.instance
      testWindow = $('<div></div>')
      ready = true
      loadFixtures("login.html")

    waitsFor ->
      return ready

  describe "#_setEmail", ->

    it "assigns the zmail", ->
      login._setEmail(sampleEmail)
      expect(login.my.zmail).toEqual(sampleEmail)

    it "assigns the a cookie", ->
      login._setEmail(sampleEmail)
      expect($.cookie('zmail')).toEqual(sampleEmail)

  describe "#_toggleLogIn", ->


    describe "with a temp or perm session", ->

     beforeEach ->
        login.my.session = "temp"
        $.cookie('z_type_email', '')

      it "hides register link", ->

        login._toggleLogIn()
        expect($('a.register').parent()).toHaveClass('hidden')

      it "hides the account link when z_type_email", ->
        $.cookie('z_type_email', 'profile')
        login._toggleLogIn()
        expect($('a.account').parent()).not.toHaveClass('hidden')

    describe "without a session", ->



