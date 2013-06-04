define(['jquery'], function ($) {
  (function($) {
    $.fn.lead_service = function(options) {

      var form_div = $(this);

      /**
       * show/hide optional fields before handing control over
       */
      var pre_update_form = function() {

          $('.lead_search_state').val($.cookie('long_state'));
          $('.lead_search_city').val($.cookie('city'));
          $('.lead_search_zip').val($.cookie('zip'));

          // Show Last Name if specified
          if (options.show_hide_params && options.show_hide_params.last_name_required == "1") {
            $('.lead_last_name').show();
          } else {
            $('.lead_last_name').hide();
            $('.lead_first_name label').html("<em>*</em> Your Name:")
          }

          if (options.show_hide_params && options.show_hide_params.phone_required == "1") {
            $('em#phone_number').show();
          } else {
            $('em#phone_number').hide();
          }

          // Show beds & baths if specified
          if (options.show_hide_params && options.show_hide_params.bed_bath_leads == "1") {
            $('.beds_baths').show();
          } else {
            $('.beds_baths').hide();
          }

          // Show price range if specified
          if (options.show_hide_params && options.show_hide_params.show_price_range == "1") {
            $('.price_range').show();
          } else {
            $('.price_range').hide();
          }
          if (options.show_hide_params && options.show_hide_params.price_range_required == "1") {
            $('em#price_range').show();
          } else {
            $('em#price_range').hide();
          }

          // Show reason for move if specified
          if (options.show_hide_params && options.show_hide_params.show_reason_for_move == "1") {
            $('.reason_for_move').show();
          } else {
            $('.reason_for_move').hide();
          }
          if (options.show_hide_params && options.show_hide_params.reason_for_move_required == "1") {
            $('em#reason_for_move').show();
          } else {
            $('em#reason_for_move').hide();
          }

          // Show confirmation email if required
          if (options.show_hide_params && options.show_hide_params.confirm_email_required == "1") {
            $('.confirm_email').show();
          } else {
            $('.confirm_email').hide();
          }

          // Show move date or move date preference if required
          if (options.show_hide_params && options.show_hide_params.show_move_date == "1") {
            $('.lead_move_date').show();

            if (options.show_hide_params.move_date_required == "1") {
              $('em#move_date').show();
            } else {
              $('em#move_date').hide();
            }

            $('.lead_move_date_preference').hide();
          } else {
            $('.lead_move_date_preference').show();

            if (options.show_hide_params && options.show_hide_params.move_date_preference_required == "1") {
              $('em#move_date_preference').show();
            } else {
              $('em#move_date_preference').hide();
            }

            $('.lead_move_date').hide();
          }
      }

      var formLoad = function() {
        url = buildNewUrl(opts.form_params);              // build new lead url
        form_div.load(url, function(){                    // get /:version/leads/new?lead[attribute]=value&...
          pre_update_form();
          opts.update_form();                             // re-draw the form
          $('.lead_form', form_div).submit( submitLead ); // re-bind the submit behavior
          form_div.show();
        });
      };

      var buildNewUrl = function(params) {
        var base = '/v1/leads/new?';
        var uri = '';
        if(params.session_id == undefined) { // Use the session ID if provided, otherwise set it to WT.vt_sid
          var session_id = 'webtrends_session';
          if(typeof(WT) != 'undefined' && WT.vt_sid != 'undefined' && WT.vt_sid != "" && WT.vt_sid != null) { session_id = WT.vt_sid; }
          params.session_id = session_id;
        }
        for(var i in params.required_fields) {
          uri += "lead[required_fields][]=" + params.required_fields[i] + "&";
        }
        delete params.required_fields;

        for(attr in params){
          uri += "lead[" + attr + "]=" + params[attr] + "&";
        }
        uri = uri.substring(0, uri.length - 1);
        base += encodeURI(uri);
        return base;
      };

      var submitLead = function() {
        var caller = $(this);
        if( this.beenSubmitted ) return false;
        this.beenSubmitted = true;
        $.ajax({
          url: '/v1/leads/ajax.js',
          type: 'POST',
          data: $(this).serialize(),
          success: function(response){
            opts.lead_saved();
          },
          error: function(req, status, err) {
            var parent = caller.parent();
            caller.replaceWith(req.responseText);
            pre_update_form();
            opts.update_form();
            $('.lead_form', parent).submit( submitLead );
            return false;
          }
        });
        return false;
      };

      var thankYou   = function(){ form_div.html('Thank you!'); };
      var updateForm = function(){ };

      var defaults = {
        update_form : updateForm,
        lead_saved  : thankYou
      };
      var opts = jQuery.extend(defaults, options);

      return this.each(function(){
        formLoad();
      });

    };
  })(jQuery);
});
