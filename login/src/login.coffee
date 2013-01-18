define ["jquery", "jquery-cookie-rjs", "jquery-prmdialog"], ($, cookie, prmDialog) ->
  my =
    zid: $.cookie('zid')
    session: (($.cookie("sgn") is "temp") or ($.cookie("sgn") is "perm"))
    currentUrl: window.location.href
    registrationForm: $("#zutron_register_form")
    popupTypes: ["login", "register", "change"]

  bindRegistrationLinks = (type) ->
    modalDiv = $("#zutron_" + type + "_form")
    $("a." + type).click ->
      $('.prm_dialog').prm_dialog_close()
      triggerModal modalDiv

  wireupSocialLinks = (div) ->
    baseUrl = zutron_host + "?zid_id=" + my.zid + "&referrer=" + my.currentUrl + "&technique="
    fbLink = div.find("a.icon_facebook48")
    twitterLink = div.find("a.icon_twitter48")
    googleLink = div.find("a.icon_google_plus48")
    bindSocialLink fbLink, baseUrl + "facebook"
    bindSocialLink twitterLink, baseUrl + "twitter"
    bindSocialLink googleLink, baseUrl + "google_oauth2"

  enableLoginRegistration = ->
    $('#registaration_form form').submit ->
      submitEmailRegistration $(this)

    $('#zutron_change_form form').submit ->
      submitChangeEmail $(this)

    $('#zutron_login_form form').submit ->
      submitLogin $(this)

  redirectOnSuccess = (obj) ->
    my.registrationForm.prm_dialog_close()
    window.location.assign obj.redirectUrl if obj.redirectUrl

  submitEmailRegistration = (form) ->
    form.find("input#state").val my.zid
    form.find("input#origin").val window.location.href

    $.ajax
      type: 'POST'
      data: form.serialize()
      url: "#{zutron_host}/auth/identity/register"
      beforeSend: (xhr) ->
        xhr.overrideMimeType "text/json"
        xhr.setRequestHeader "Accept", "application/json"
      success: (data)->
        if data['redirectUrl'] # To catch IE8 XDR failures
          redirectOnSuccess data
        else
          generateErrors(data, form.parent().find(".errors"))

      error: (errors) ->
        generateErrors $.parseJSON(errors.responseText), form.parent().find(".errors")

  submitLogin = (form)->
    form.find("input#state").val my.zid
    form.find("input#origin").val window.location.href
    $.ajax
      type: "POST"
      data: form.serialize()
      url:  "#{zutron_host}/auth/identity/callback"
      beforeSend: (xhr) ->
        xhr.overrideMimeType "text/json"
        xhr.setRequestHeader "Accept", "application/json"
      success: (data)->
        if data['redirectUrl'] # To catch IE8 XDR failures
          redirectOnSuccess data
        else
          generateErrors(data, form.parent().find(".errors"))
      error: (errors) ->
        generateErrors $.parseJSON(errors.responseText), form.parent().find(".errors")

  submitChangeEmail = (form)->
    form.find("input#state").val my.zid
    form.find("input#origin").val window.location.href
    new_email =
      profile:
        email: $('input[name="profile"]').val()

    $.ajax
      type: "GET"
      data: new_email
      datatype: 'json'
      url:  zutron_host + "/zids/" + my.zid + "/profile/edit.json"
      beforeSend: (xhr) ->
        xhr.overrideMimeType "text/json"
        xhr.setRequestHeader "Accept", "application/json"
      success: (data) ->
        error = null
        if data? and data.base # To catch IE8 XDR failures
          error = {'email': data.base}
          generateErrors error, form.parent().find(".errors")
        else
          $('#zutron_change_form').prm_dialog_close()
      error: (errors) ->
        generateErrors $.parseJSON(errors.responseText), form.parent().find(".errors")

  clearErrors = (div)->
    div.find('.errors').empty()
    div.find('form p').removeClass('error')

  formatError = (key, value) ->
    switch key
      when "base" then value
      when "auth_key"
        if value then value else ''
      when "email"
        if value then "Email #{value}" else ''
      when "password"
        if value then "Password #{value}" else ''
      when "password_confirmation" then "Password Confirmation #{value}"

  generateErrors = (error, box) ->
    clearErrors box.parent()
    messages = ''

    if error?
      form = box.parent().find 'form'
      for own key, value of error
        form.find("##{key}").parent('p').addClass 'error'
        formattedError = formatError(key, value)
        messages += "<li>#{formattedError}</li>" if formatError
      form.find('.error input:first').focus()
    else
      messages += "An error has occured."
    box.append "<ul>#{messages}</ul>"


  triggerModal = (div) ->
    clearErrors div
    div.prm_dialog_open()
    wireupSocialLinks div
    div.on "click", "a.close", ->
      div.prm_dialog_close()

  toggleRegistrationDiv = (div) ->
    unless my.session
      div.show()
      wireupSocialLinks div
      for type in my.popupTypes
        bindRegistrationLinks type

  redirectTo = (url) ->
    $.ajax
      type: "get"
      url: zutron_host + "/ops/heartbeat/riak"
      success: ->
        window.location.assign url
      error: ->
        my.registrationForm.prm_dialog_close()
        $("#zutron_login_form").prm_dialog_close()
        triggerModal $("#zutron_error")

  bindSocialLink = (link, url) ->
    link.on "click", ->
      staySignedIn = $(".zutron_login_popup :checkbox")[0].checked or $(".zutron_register_popup :checkbox")[0].checked
      if staySignedIn
        options =
          path: "/"
          domain: window.location.host
        $.cookie "stay", "true", options
      else
        expireCookie "sgn"
      redirectTo url

  toggleLogIn = ->
    regLink = $("#login_links li a.register")
    logLink = $("#login_links li a.login")
    changeLink = $('a.change_email')
    if my.session
      changeLink.show()
      regLink.hide()
      logLink.attr("class", "logout").text "Logout"
    else
      regLink.show()
      logLink.attr("class", "login").text "Login"

  logOut = ->
    expireCookie "zid"
    expireCookie "sgn"
    window.location.replace my.currentUrl

  expireCookie = (cookie) ->
    expire = new Date(1)
    domain = "." + window.location.host
    options =
      expires: expire
      path: "/"
      domain: domain

    $.cookie cookie, "", options

  welcomeMessage = ->
    triggerModal $("#welcome_message")  if $.cookie("user_type") is "new"
    expireCookie "user_type"

  init = ->
    $(document).ready ->

      $('body').bind 'new_zid_obtained', ->
        my.zid = $.cookie('zid')

      enableLoginRegistration()
      toggleLogIn()

      welcomeMessage()

      for type in my.popupTypes
        bindRegistrationLinks type

      $("#login_links li a.logout").click logOut


  init: init
  wireupSocialLinks: wireupSocialLinks
  toggleRegistrationDiv: toggleRegistrationDiv
  expireCookie: expireCookie
  session: my.session

