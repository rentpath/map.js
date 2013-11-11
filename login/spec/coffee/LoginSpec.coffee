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

      it "flips the login link class", ->
        loginLink = $('a.login')
        login._toggleLogIn()
        expect(loginLink).toHaveClass('logout')
        expect(loginLink).not.toHaveClass('login')

      it "hides the account link when z_type_email", ->
        $.cookie('z_type_email', 'profile')
        login._toggleLogIn()
        expect($('a.account').parent()).not.toHaveClass('hidden')

      it "sets the login link text to Log Out", ->
        loginLink = $('a.login')
        login._toggleLogIn()
        expect(loginLink).toHaveText('Log Out')

      it "hides marked elements based on logged in state", ->
        login._toggleLogIn()
        elements = $('.js_hidden_if_logged_in')
        expect(elements).toHaveCss(display: 'none')

      it "does not hide marked elements based on logged out state", ->
        login._toggleLogIn()
        elements = $('.js_hidden_if_logged_out')
        expect(elements).not.toHaveCss(display: 'none')

    describe "without a session", ->

      beforeEach ->
        login.my.session = ""

      it "doesn't hide register link", ->
        login._toggleLogIn()
        expect($('a.register').parent()).not.toHaveClass('hidden')

      it "flips the login link class", ->
        loginLink = $('a.login')
        login._toggleLogIn()
        expect(loginLink).not.toHaveClass('logout')
        expect(loginLink).toHaveClass('login')

      it "keeps the account link hidden", ->
        login._toggleLogIn()
        expect($('a.account').parent()).toHaveClass('hidden')

      it "sets the login link text to Log In", ->
        loginLink = $('a.logout')
        login._toggleLogIn()
        expect(loginLink).toHaveText('Log In')

      it "does not hide marked elements based on logged in state", ->
        login._toggleLogIn()
        elements = $('.js_hidden_if_logged_out')
        expect(elements).toHaveCss(display: 'none')

      it "hides marked elements based on logged out state", ->
        login._toggleLogIn()
        elements = $('.js_hidden_if_logged_in')
        expect(elements).not.toHaveCss(display: 'none')
