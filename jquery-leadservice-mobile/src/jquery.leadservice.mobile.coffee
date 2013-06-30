define ['jquery', 'jquery-cookie-rjs'], ($) ->
  class LeadForm
    constructor: (@container) ->
      @form = @container.find('#lead_form')
      @errorMsg = @container.find('.full_errors')
      @form.submit @submit
      @updateFormByCookie()
      @showOptionalFields()

    getSessionID: ->
      if WH?.userID and WH?.sessionID
        "#{WH.userID}.#{WH.sessionID}"
      else
        "no_session_id_#{new Date().getTime()}"

    getWebsite: -> window.location.host

    showOptionalFields: ->
      if $('#lead_optional_fields').length
        optional = $('#lead_optional_fields').val().split(',')
      else
        optional = []

      if $('#lead_required_fields').length
        required = $('#lead_required_fields').val().split(',')
      else
        required = []

      $(optional.concat(required)).each (index, element) ->
        $(".lead_#{element}").show()

    saveDataToCookie: ->
      return if not (typeof(JSON) and typeof(JSON.stringify))

      data =
        firstName: @form.find('#lead_first_name').val(),
        lastName:  @form.find('#lead_last_name').val(),
        email:     @form.find('#lead_email').val(),
        phone:     @form.find('#lead_phone').val(),
        beds:      @form.find('#lead_beds').val()
        baths:     @form.find('#lead_baths').val(),
        message:   @form.find('#lead_message').val()

      $.cookie("lead", JSON.stringify(data))

    updateFormByCookie: ->
      return if not $.cookie("lead")

      data = $.parseJSON $.cookie("lead")
      return if not (typeof(data) is 'object')

      @form.find("#lead_first_name").val(data.firstName)
      @form.find("#lead_last_name").val(data.lastName)
      @form.find("#lead_email").val(data.email)
      @form.find("#lead_phone").val(data.phone)
      @form.find("#lead_message").val(data.message)
      @form.find("#lead_beds").val(data.beds)
      @form.find("#lead_baths").val(data.baths)
      @form.find("#lead_session_id").val(@getSessionID())
      @form.find('#lead_website').val(@getWebsite())

    thankYouTemplate: ->
      """
      <div id="lead_thank_you">
        <h2>Thank you for your inquiry.</h2>
        <p>The information you provided will be sent to the appropriate location. If you have additional questions, contact the property at the number provided.</p>
      </div>
      """

    submit: (e) =>
      e.preventDefault()

      @saveDataToCookie()

      $.ajax
        type: 'POST'
        url: @form.attr("action")
        data: @form.serialize()
      .done =>
        @container.html @thankYouTemplate()
        $(document).trigger 'leadservice:success'
      .fail (res) =>
        responseText = $(res.responseText)
        @errorMsg.html responseText.find('.full_errors').html()
        $(document).trigger 'leadservice:fail'

  $ ->
    new LeadForm($('#lead_form_container'))
