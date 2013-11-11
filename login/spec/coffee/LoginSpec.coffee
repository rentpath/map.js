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

  describe "#_encodeURL", ->

    it "encodes the hash", ->
      url = "http://127.0.0.1/foo#bar"
      expect(login._encodeURL(url)).toBe("http://127.0.0.1/foo%23bar")

    it "does not add a trailing #", ->
      url = "http://127.0.0.1/foo"
      expect(login._encodeURL(url)).toBe("http://127.0.0.1/foo")

  describe "#_setEmail", ->

    it "assigns the zmail", ->
      login._setEmail(sampleEmail)
      expect(login.my.zmail).toEqual(sampleEmail)

    it "assigns the a cookie", ->
      login._setEmail(sampleEmail)
      expect($.cookie('zmail')).toEqual(sampleEmail)

  describe "#_showRegister", ->

    it "doesn't hide the link", ->
      login._showRegister()
      expect($('a.register').parent()).not.toHaveClass('hidden')

  describe "#_hideRegister", ->

    it "hides the link", ->
      login._hideRegister()
      expect($('a.register').parent()).toHaveClass('hidden')

  describe "#_showAccount", ->

    it "keeps the account link hidden without z_type_email", ->
      $.cookie('z_type_email', '')
      login._showAccount()
      expect($('a.account').parent()).toHaveClass('hidden')

    it "hides the account link when z_type_email", ->
      $.cookie('z_type_email', 'profile')
      login._showAccount()
      expect($('a.account').parent()).not.toHaveClass('hidden')

  describe "#_showLogout", ->

    it "flips the login link class", ->
      loginLink = $('a.login')
      login._showLogout()
      expect(loginLink).toHaveClass('logout')
      expect(loginLink).not.toHaveClass('login')

    it "sets the login link text to Log Out", ->
      loginLink = $('a.login')
      login._showLogout()
      expect(loginLink).toHaveText('Log Out')

  describe "#_showLogin", ->

    it "flips the login link class", ->
      loginLink = $('a.login')
      login._showLogin()
      expect(loginLink).not.toHaveClass('logout')
      expect(loginLink).toHaveClass('login')

    it "sets the login link text to Log In", ->
      loginLink = $('a.logout')
      login._showLogin()
      expect(loginLink).toHaveText('Log In')

  describe "#_toggleElementsWhenLoggedIn", ->

    it "hides marked elements based on logged in state", ->
      login._toggleElementsWhenLoggedIn()
      elements = $('.js_hidden_if_logged_in')
      expect(elements).toHaveCss(display: 'none')

    it "does not hide marked elements based on logged out state", ->
      login._toggleElementsWhenLoggedIn()
      elements = $('.js_hidden_if_logged_out')
      expect(elements).not.toHaveCss(display: 'none')

  describe "#_toggleElementsWhenLoggedOut", ->

    it "does not hide marked elements based on logged in state", ->
      login._toggleElementsWhenLoggedOut()
      elements = $('.js_hidden_if_logged_out')
      expect(elements).toHaveCss(display: 'none')

    it "hides marked elements based on logged out state", ->
      login._toggleElementsWhenLoggedOut()
      elements = $('.js_hidden_if_logged_in')
      expect(elements).not.toHaveCss(display: 'none')

  describe "#_toggleSessionState", ->

    for sessionType in ["temp","perm"]

      describe "with a #{sessionType} session", ->

        beforeEach ->
          login.my.session = sessionType
          spyOn login, '_hideRegister'
          spyOn login, '_showLogout'
          spyOn login, '_showAccount'
          spyOn login, '_toggleElementsWhenLoggedIn'
          login._toggleSessionState()

        it "hides register link", ->
          expect(login._hideRegister).toHaveBeenCalled()

        it "shows logout", ->
          expect(login._showLogout).toHaveBeenCalled()

        it "shows account", ->
          expect(login._showAccount).toHaveBeenCalled()

        it "toggles elements when logged in", ->
          expect(login._toggleElementsWhenLoggedIn).toHaveBeenCalled()

    describe "without a session", ->

      beforeEach ->
        login.my.session = ""
        spyOn login, '_showRegister'
        spyOn login, '_showLogin'
        spyOn login, '_toggleElementsWhenLoggedOut'
        login._toggleSessionState()

      it "shows register link", ->
        expect(login._showRegister).toHaveBeenCalled()

      it "shows login", ->
        expect(login._showLogin).toHaveBeenCalled()

      it "toggles elements when logged out", ->
        expect(login._toggleElementsWhenLoggedOut).toHaveBeenCalled()
