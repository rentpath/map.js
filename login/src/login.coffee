define ['jquery'], ($) ->
  class Login
    constructor: ->
      @_overrideDependencies()

      @my =
        zid: $.cookie 'zid'
        session: $.cookie("sgn") is "temp" or $.cookie("sgn") is "perm"
        currentUrl: window.location.href
        popupTypes: ["login", "register", "account", "reset", "confirm"]

      $(document).ready =>
        $('body').bind 'new_zid_obtained', =>
          @my.zid = $.cookie 'zid'

        @_welcomeMessage()
        @_toggleLogIn()
        @_enableLoginRegistration()

        $.each @my.popupTypes, (index, type) =>
          @_bindForms type

        $("a.logout").click (e) => @_logOut e

    toggleRegistrationDiv: ($div) ->
      unless @my.session
        @wireupSocialLinks $div.show()
        $.each @my.popupTypes, (type) ->
          @_bindForms type

    expireCookie: (cookie) ->
      options =
        expires: new Date(1)
        path: "/"
        domain: ".#{window.location.host}"
      $.cookie cookie, "", options

    wireupSocialLinks: ($div) ->
      baseUrl = "#{zutron_host}?zid_id=#{@my.zid}&referrer=#{@my.currentUrl}&technique="
      fbLink = $div.find("a.icon_facebook48")
      twitterLink = $div.find("a.icon_twitter48")
      googleLink = $div.find("a.icon_google_plus48")
      @_bindSocialLink fbLink, "#{baseUrl}facebook", $div
      @_bindSocialLink twitterLink, "#{baseUrl}twitter", $div
      @_bindSocialLink googleLink, "#{baseUrl}google_oauth2", $div

    _welcomeMessage: ->
      @_triggerModal $("#welcome_message") if $.cookie("user_type") is "new"
      @expireCookie "user_type"

    _enableLoginRegistration: =>
      $('#zutron_register_form form').submit (e) =>
        @_submitEmailRegistration $(e.target)
      $('#zutron_account_form form').submit (e) =>
        @_submitChangeEmail $(e.target)
      $('#zutron_login_form form').submit (e) =>
        @_submitLogin $(e.target)
      $('#zutron_reset_form form').submit (e) =>
        @_submitPasswordReset $(e.target)
      $('#zutron_confirm_form form').submit (e) =>
        @_submitPasswordConfirm $(e.target)

    _submitEmailRegistration: ($form) =>
      @_setHiddenValues $form
      $.ajax
        type: 'POST'
        data: $form.serialize()
        url: "#{zutron_host}/auth/identity/register"
        beforeSend: (xhr) ->
          xhr.overrideMimeType "text/json"
          xhr.setRequestHeader "Accept", "application/json"
        success: (data) =>
          if data['redirectUrl'] # IE8 XDR Fallback
            @_redirectOnSuccess data, $form
          else
            @_generateErrors(data, $form.parent().find(".errors"))
        error: (errors) =>
          @_generateErrors $.parseJSON(errors.responseText), $form.parent().find(".errors")

    _submitLogin: ($form) ->
      @_setHiddenValues $form
      $.ajax
        type: "POST"
        data: $form.serialize()
        url:  "#{zutron_host}/auth/identity/callback"
        beforeSend: (xhr) ->
          xhr.overrideMimeType "text/json"
          xhr.setRequestHeader "Accept", "application/json"
        success: (data) =>
          if data['redirectUrl'] # IE8 XDR Fallback
            @_redirectOnSuccess data, $form
          else
            @_generateErrors(data, $form.parent().find(".errors"))
        error: (errors) =>
          @_generateErrors $.parseJSON(errors.responseText), $form.parent().find(".errors")

    _submitChangeEmail: ($form)->
        @_setHiddenValues $form
        new_email =
          profile:
            email: $('input[name="new_email"]').val()
            email_confirmation: $('input[name="new_email_confirm"]').val()
        $.ajax
          type: "GET"
          data: new_email
          datatype: 'json'
          url:  "#{zutron_host}/zids/#{@my.zid}/profile/edit.json"
          beforeSend: (xhr) ->
            xhr.overrideMimeType "text/json"
            xhr.setRequestHeader "Accept", "application/json"
          success: (data) =>
            if data? and data.email # IE8 XDR Fallback
              error = {'email': data.email}
              @_generateErrors error, $form.parent().find ".errors"
            else
              $('#zutron_account_form').prm_dialog_close()
          error: (errors) =>
            @_generateErrors $.parseJSON(errors.responseText), $form.parent().find ".errors"

    _submitPasswordReset: ($form) ->
      $.ajax
        type: 'POST'
        data: $form.serialize()
        url: "#{zutron_host}/password_reset"
        beforeSend: (xhr) ->
          xhr.overrideMimeType "text/json"
          xhr.setRequestHeader "Accept", "application/json"
        success: (data) =>
          if data? and data.error # IE8 XDR Fallback
            error = {'password': data.error}
            @_generateErrors error, $form.parent().find ".errors"
          else
            $form.parent().empty()
            $('.reset_success').html(data.success).show()
            @_determineClient $form
        error: (errors) =>
          @_generateErrors $.parseJSON(errors.responseText), $form.parent().find ".errors"

    _submitPasswordConfirm: ($form) ->
      $.ajax
        type: 'POST'
        data: $form.serialize()
        url: "#{zutron_host}/password_confirmation"
        beforeSend: (xhr) ->
          xhr.overrideMimeType "text/json"
          xhr.setRequestHeader "Accept", "application/json"
        success: (data) =>
          if data? and data.error # IE8 XDR Fallback
            error = {'password': data.error}
            @_generateErrors error, $form.parent().find ".errors"
          else
            $form.parent().empty()
            $('.reset_success').html(data.success).show()
            @_determineClient $form
        error: (errors) =>
          @_generateErrors $.parseJSON(errors.responseText), $form.parent().find ".errors"

    _clearInputs: (formID) ->
      $inputs = $(formID + ' input[type="email"]').add $(formID + ' input[type="password"]')
      $labels = $("#z_form_labels label")
      $inputs.each (index, elem) ->
        $(elem).focus ->
          $($labels[index]).hide()
        $(elem).blur ->
          if $(elem).val() is ''
            $($labels[index]).show()
        $($labels[index]).click ->
          $inputs[index].focus()

    _redirectOnSuccess: (obj, $form) ->
      $form.prm_dialog_close()
      window.location.assign obj.redirectUrl if obj.redirectUrl

    _generateErrors: (error, $box) ->
      @_clearErrors $box.parent()
      messages = ''
      if error?
        $form = $box.parent().find 'form'
        $.each error, (key, value) =>
          $form.find("##{key}").parent('p').addClass 'error'
          formattedError = @_formatError key, value
          messages += "<li>#{formattedError}</li>"
          $form.find('.error input:first').focus()
      else
        messages += "An error has occured."
      $box.append "<ul>#{messages}</ul>"

    _formatError: (key, value) ->
      switch key
        when "base" then value
        when "auth_key"
          if value then value else ''
        when "email"
          if value then "Email #{value}" else ''
        when "password"
          if value then "Password #{value}" else ''
        when "password_confirmation" then "Password Confirmation #{value}"

    _toggleLogIn: ->
      $regLink = $("a.register")
      $logLink = $("a.login")
      $changeLink = $('a.account')

      if @my.session
        $changeLink.parent().removeClass 'hidden'
        $regLink.parent().addClass 'hidden'
        $logLink.addClass("logout").text 'Logout'
      else
        $regLink.parent().removeClass 'hidden'
        $logLink.addClass("login").text 'Login'

    _bindForms: (type) ->
      formID = "#zutron_#{type}_form"

      # TODO move dependencies to bottom of page
      if @MOBILE
        @wireupSocialLinks $(formID)

      @_clearInputs formID

      $("a.#{type}").click =>
        $('.prm_dialog').prm_dialog_close()
        @_triggerModal $(formID)

    _triggerModal: ($div) =>
        @_clearErrors $div
        $div.prm_dialog_open();
        $div.on "click", "a.close", ->
          $div.prm_dialog_close()
        @wireupSocialLinks $div

    _clearErrors: ($div) ->
      $div.find('form p').removeClass('error')
      $div.find('.errors').empty()

    _bindSocialLink: ($link, url, $div) ->
      $link.on "click", =>
        staySignedIn = $div.find('input[type="checkbox"]').attr('checked')
        if staySignedIn
          options =
            path: "/"
            domain: window.location.host
          $.cookie "stay", "true", options
        else
          @expireCookie "sgn"
        @_redirectTo url

    _logOut: (e) ->
      e.preventDefault()
      @expireCookie "zid"
      @expireCookie "sgn"
      window.location.replace @my.currentUrl

    _redirectTo: (url) ->
      $.ajax
        type: "get"
        url: zutron_host + "/ops/heartbeat/riak"
        success: ->
          window.location.assign url
        error: =>
          @my.registrationForm.prm_dialog_close()
          $("#zutron_login_form, #zutron_registration").prm_dialog_close()
          @_triggerModal $("#zutron_error")

    _setHiddenValues: ($form)->
      $form.find("input#state").val @my.zid
      $form.find("input#origin").val @my.currentUrl

    _determineClient: ($form) =>
        if @my.currentUrl.indexOf('client') > 0 and (navigator.userAgent.match(/Android/i) or navigator.userAgent.match(/iPhone/i))
          clients = ["iOS", "android"]
          $.each clients, (client) =>
            my_client = @my.currentUrl.substring(@my.currentUrl.indexOf('client'), location.href.length)
            my_client = my_client.split("=")[1].toLowerCase()
            @_createAppButton my_client
            false

    _createAppButton: (client) ->
      launch_url = "a" if client is 'ios'
      launch_url = "b" if client is 'android'
      btn = "<a href='#{launch_url}' class='#{client} app_button'>#{client}</a>"
      $('#app_container').html btn

    _overrideDependencies: ->
      @MOBILE = window.location.host.match(/(^m\.|^local\.m\.)/)?
      @BIGWEB = not @MOBILE
      if @BIGWEB
        @_clearInputs = ->
      if @MOBILE
        $.fn.prm_dialog_close = ->
        $.fn.prm_dialog_open  = ->
        @_triggerModal = ->

  instance: {}
  init: -> @instance = new Login()
  wireupSocialLinks: -> @instance.wireupSocialLinks()
  toggleRegistrationDiv: -> @instance.toggleRegistrationDiv()
  expireCookie: -> @instance.expireCookie()
  session: -> @instance.my.session