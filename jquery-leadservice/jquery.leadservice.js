define(['jquery', 'jquery-cookie-rjs'], function ($) {
    //TODO: Rewrite all variables and function calls with underscores -BNS
    (function($) {
        $.fn.lead_service = function(options) {

            var form_div = $(this);
            // show/hide bed bath fields before handing control over
            var pre_update_form = function() {

                $(".lead_ef_id").val($.cookie('ef_id'));
                $('.lead_search_state').val($.cookie('long_state'));
                $('.lead_search_city').val($.cookie('city'));
                $('.lead_search_zip').val($.cookie('zip'));
                // Hide show dynamic attributes
                if (options.show_hide_params && !options.is_mobile) {
                    // Show Last Name if specified
                    if (options.show_hide_params.last_name_required == "1") {
                        $('.lead_last_name').show();
                    } else {
                        $('.lead_last_name').hide();
                        $('.lead_first_name label').html("<em>*</em> Your Name:");
                    }

                    if (options.show_hide_params.phone_required == "1") {
                        $('em#phone_number').show();
                    } else {
                        $('em#phone_number').hide();
                    }

                    // Show beds & baths if specified
                    if (options.show_hide_params.bed_bath_leads == "1") {
                        $('.beds_baths').show();
                    } else {
                        $('.beds_baths').hide();
                    }

                    if (options.show_hide_params.bed_bath_leads_required == "1") {
                        $('em#beds').show();
                        $('em#baths').show();
                    } else {
                        $('em#beds').hide();
                        $('em#baths').hide();
                    }

                    // Show price range if specified
                    if (options.show_hide_params.show_price_range == "1") {
                        $('div.price_range').show();
                    } else {
                        $('div.price_range').hide();
                    }
                    if (options.show_hide_params.price_range_required == "1") {
                        $('em#price_range').show();
                    } else {
                        $('em#price_range').hide();
                    }

                    // Show reason for move if specified
                    if (options.show_hide_params.show_reason_for_move == "1") {
                        $('.reason_for_move').show();
                    } else {
                        $('.reason_for_move').hide();
                    }
                    if (options.show_hide_params.reason_for_move_required == "1") {
                        $('em#reason_for_move').show();
                    } else {
                        $('em#reason_for_move').hide();
                    }

                    // Show confirmation email if required
                    if (options.show_hide_params.confirm_email_required == "1") {
                        $('.lead_confirm_email').show();
                    } else {
                        $('.lead_confirm_email').hide();
                    }

                    // Show move date or move date preference if required
                    if (options.show_hide_params.show_move_date == "1") {
                        $('.lead_move_date').show();

                        if (options.show_hide_params.move_date_required == "1") {
                            $('em#move_date').show();
                        } else {
                            $('em#move_date').hide();
                        }

                        $('.lead_move_date_preference').hide();
                    } else {
                        $('.lead_move_date_preference').show();

                        if (options.show_hide_params.move_date_preference_required == "1") {
                            $('em#move_date_preference').show();
                        } else {
                            $('em#move_date_preference').hide();
                        }

                        $('.lead_move_date').hide();
                    }

                }
            };

            var getCookieObj = function() {
                var cookie = $.cookie('lead');
                if (!cookie) return null;

                var cookieObj = {
                    firstName: '',
                    lastName: '',
                    email: '',
                    phone: '',
                    address: '',
                    city: '',
                    state: '',
                    zip: '',
                    moveDate: '',
                    moveDatePreference: '',
                    message: '',
                    optInBrochure: '',
                    optInNewsletter: '',
                    beds: '',
                    baths: '',
                    priceRange: '',
                    reasonForMove: ''
                };

                var arr = cookie.split('|');
                var i = 0;

                $.each(cookieObj,
                function(key, val) {
                    cookieObj[key] = arr[i];
                    i++;
                });

                return cookieObj;
            };

            var updateFromCookie = function() {
                var cookie = getCookieObj();
                var form = form_div.find('form');

                if (cookie) {
                    var brochure = cookie.optInBrochure === '1' ? true: false;
                    var newsletter = cookie.optInNewsletter === '1' ? true: false;
                    form.find('input.lead_opt_in_brochure').attr('checked', brochure);
                    form.find('input.lead_opt_in_newsletter').attr('checked', newsletter);
                    form.find('input.lead_first_name').val(cookie.firstName.replace(/\+/g, ' '));
                    form.find('input.lead_last_name').val(cookie.lastName.replace(/\+/g, ' '));
                    form.find('input.lead_email').val(cookie.email);
                    form.find('input.lead_phone').val(cookie.phone);
                    form.find('input.lead_address').val(cookie.address);
                    form.find('input.lead_city').val(cookie.city);
                    form.find('input.lead_state').val(cookie.state);
                    form.find('input.lead_zip').val(cookie.zip);
                    form.find('input.lead_move_date').val(cookie.moveDate);
                    form.find('textarea.lead_message').val(cookie.message.replace(/\+/g, ' '));
                    form.find("select.lead_move_date_preference>option[value='" + cookie.moveDatePreference + "']").attr("selected", "selected");
                    form.find("select.lead_beds>option[value='" + cookie.beds + "']").attr("selected", "selected");
                    form.find("select.lead_baths>option[value='" + cookie.baths + "']").attr("selected", "selected");
                    form.find("select.lead_price_range>option[value='" + cookie.priceRange + "']").attr("selected", "selected");
                    form.find("select.lead_reason_for_move>option[value='" + cookie.reasonForMove.replace(/\+/g, ' ') + "']").attr("selected", "selected");
                } else {
                    // default to check checkboxes
                    form.find('input.lead_opt_in_brochure').attr('checked', true);
                    form.find('input.lead_opt_in_newsletter').attr('checked', true);
                }
            };

            var updateFields = function() {
                updateFromCookie();
                pre_update_form();
                opts.update_form();
                $('.lead_form', form_div).submit(
                    submitLead
                );
                if(!opts.form_params.is_mobile){
                    form_div.show();
                }
            };

            var formLoad = function() {
                if (opts.form_params.is_mobile)
                    updateFields();
                else {
                    url = buildNewUrl(opts.form_params);
                    form_div.load(url, updateFields);
                }
            };

            var buildNewUrl = function(params) {
                var base = '/v2/leads/new?';
                var uri = '';
                if (params.session_id == undefined) {
                    // Use the session ID if provided, otherwise set it to WT.vt_sid
                    var session_id = 'webtrends_session';
                    if (typeof(WT) != 'undefined' && WT.vt_sid != 'undefined' && WT.vt_sid != "" && WT.vt_sid != null) {
                        session_id = WT.vt_sid;
                    }
                    params.session_id = session_id;
                }

                $.each(params.required_fields, function(k,v){
                    uri += "lead[required_fields][]=" + v + "&";
                });

                delete params.required_fields;

                $.each(params, function(k, v) {
                    uri += "lead[" + k + "]=" + v + "&";
                });
                uri = uri.substring(0, uri.length - 1);
                base += encodeURI(uri);
                return base;
            };

            var submitLead = function() {
                var caller = $(this);
                if (this.beenSubmitted) return false;
                this.beenSubmitted = true;
                var status = 'fail';
                $.ajax({
                    url: '/v2/leads/ajax.js',
                    type: 'POST',
                    data: $(this).serialize(),
                    success: function(response) {
                        status = 'success';
                        opts.lead_saved();
                    },
                    error: function(req, status, err) {
                        var parent = caller.parent();
                        caller.replaceWith(req.responseText);
                        pre_update_form();
                        opts.update_form();
                        $('.lead_form', parent).submit(submitLead);
                        return false;
                    },
                    complete: function() {
                      if (status == 'success') {
                        $('body').trigger('lead_submission');
                      }
                    }
                });
                return false;
            };

            var thankYou = function() {
                form_div.html('Thank you!');
            };

            var updateForm = function() {};

            var defaults = {
                update_form: updateForm,
                lead_saved: thankYou
            };
            var opts = jQuery.extend(defaults, options);

            return this.each(function() {
                formLoad();
            });
        };
    })(jQuery);
});
