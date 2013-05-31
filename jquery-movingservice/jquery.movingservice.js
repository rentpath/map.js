define(['jquery', 'jquery-movingformservice'],function ($, movingFormService) {
    $.fn.getLeadForm = function (input_button) { //TODO: I SHOULD NOT BE A PLUGIN -BNS
        try {
            var lead_form = $(this);
            $(this).movingService({
                update_form:function () {
                    lead_form.removeClass('loading');

                    var state_from_selector = $('select#moving_lead_MovingFrom_state');
                    var city_from_selector = $('select#moving_lead_MovingFrom_city');
                    var state_to_selector = $('select#moving_lead_MovingTo_state');
                    var city_to_selector = $('select#moving_lead_MovingTo_city');

                    // Populate the 'to' location if the referer has a city/state from an AG url
                    var referrer = document.referrer;

                    // search page, details page, thank you page
                    if (/(www|local)\.(\w+\.)?apartmentguide\.com/.test(referrer) && lead_form.find('.field_error').length == 0) {
                        var segments = referrer.split('/');
                        var state = (segments[4] + '').replace('-', ' ');
                        var city = (segments[5] + '').replace('-', ' ');

                        if (!state_to_selector.val()) {
                            state_to_selector.find('option').filter(
                                function () {
                                    return (new RegExp('^' + state + '$')).test($(this).text());
                                }).attr({ selected:true });
                        }

                        if (!city_to_selector.val()) {
                            movingFormService.load_cities_and_zips(city, state, $('#moving_to_row'));
                        }
                    } else {
                        state_from_selector.change();
                        state_to_selector.change();
                        city_from_selector.change();
                        city_to_selector.change();
                        $('#moving_lead_MovingDate').datepicker({minDate:+3, maxDate:'+6M', dateFormat:"mm/dd/yy"});
                        $('#moving_lead_DayPhone').unmask().mask("(999) 999-9999");
                        $('#moving_lead_EvePhone').unmask().mask("(999) 999-9999");
                    }

                    $('.form_button_box input').val('Get Moving Quotes!');
                    $('.form_button_box input').addClass('button');
                },
                form_params:{
                    MovingTo_state:$(this).attr('data-state'),
                    MovingTo_city:$(this).attr('data-city'),
                    MovingTo_zip:$(this).attr('data-zip')
                    // required_fields: ['moving_lead_FirstName', 'moving_lead_LastName', 'moving_lead_Email', 'moving_lead_MovingFrom_state', 'MovingFrom_city', 'MovingFrom_zip', 'MovingTo_city', 'MovingTo_state', 'TypeOfMove', 'moving_lead_MovingDate']
                },
                lead_saved:function () {
                    lead_form.load('/v1/moving_lead/thankyou', '', function () {
                        if (lead_form.parent().attr('id') == "inline_leadform") {
                            $('#inline_leadform h4').hide();
                            $('#form_title').hide();
                        }

                        // Handle DART based on the current page.
                        if ($('.back_to_search_link>a.back_to_results').length > 0) {
                            $.get('http://ad.doubleclick.net/clk;240178453;63013666;e?')
                        } else {
                            $.get('http://ad.doubleclick.net/clk;240178454;63013666;f?')
                        }

                        $("#moving_lead_form").append("<IMG SRC='http://ad.doubleclick.net/activity;src=2694165;type=ReloCV;cat=LeadCV;ord=" + Math.random() * 10000000000000 + "?' WIDTH=1 HEIGHT=1 BORDER=0>");
                        // if($('#popup_property_info').length > 0) $('#popup_property_info').hide();
                    });
                },
                error:function (res) {
                    alert(res);
                }
            });
        } catch (err) {
            alert(err);

            var moving_service_error = function () {
                $('#ready_to_move .moving_form').hide();
            };
        }
    };
});
/* 2012-04-26 11:13:21 -0400 */
