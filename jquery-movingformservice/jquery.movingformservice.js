define(['jquery'], function ($) {

    (function ($) {
        $.fn.movingService = function (options) {
            var form_div = $(this);

            var formLoad = function () {

                url = buildNewUrl(opts.form_params);
                form_div.load(url, function () {
                    opts.update_form();
                    $('.moving_form', form_div).submit(submitLead);
                    setup_bindings();
                    form_div.show();
                });
            };

            var buildNewUrl = function (params) {
                var base = '/v1/moving_lead/new?';
                var uri = '';

                for (var i in params.required_fields) {
                    uri += "moving_lead[required_fields][]=" + params.required_fields[i] + "&";
                }
                delete params.required_fields;

                for (attr in params) {
                    uri += "moving_lead[" + attr + "]=" + params[attr] + "&";
                }
                uri = uri.substring(0, uri.length - 1);
                base += encodeURI(uri);

                return base;
            };

            var submitLead = function () {
                var caller = $(this);
                if (this.beenSubmitted) return false;
                this.beenSubmitted = true;
                $.ajax({
                    url:'/v1/moving_lead/ajax.js',
                    type:'POST',
                    data:$(this).serialize(),
                    success:function (response) {
                        opts.lead_saved();
                    },
                    error:function (req, status, err) {
                        var parent = caller.parent();
                        caller.replaceWith(req.responseText);
                        opts.update_form();
                        setup_bindings();
                        $('.moving_form', parent).submit(submitLead);
                        return false;
                    }
                });
                return false;
            };

            var thankYou = function () {
                form_div.html('Thank you!');
            };
            var updateForm = function () {
            };

            var defaults = {
                update_form:updateForm,
                lead_saved:thankYou
            };
            var opts = jQuery.extend(defaults, options);

            return form_div.each(function () {
                formLoad();
            });

        };

    })(jQuery);

    function setup_bindings() {
        $("select#moving_lead_MovingFrom_state").bind("change",
            function () {
                load_cities($("select#moving_lead_MovingFrom_state").val(), $("select#moving_lead_MovingFrom_city"));
            }).trigger('change');

        $("select#moving_lead_MovingTo_state").bind("change",
            function () {
                load_cities($("select#moving_lead_MovingTo_state").val(), $("select#moving_lead_MovingTo_city"));
            }).trigger('change');

        $("select#moving_lead_MovingTo_city").bind("change",
            function () {
                load_zips($("select#moving_lead_MovingTo_city").val(), $("select#moving_lead_MovingTo_state").val(), $("select#moving_lead_MovingTo_zip"));
            }).trigger('change');

        $("select#moving_lead_MovingFrom_city").bind("change",
            function () {
                load_zips($("select#moving_lead_MovingFrom_city").val(), $("select#moving_lead_MovingFrom_state").val(), $("select#moving_lead_MovingFrom_zip"));
            }).trigger('change');
    }

    function load_cities(state, target, callback) {
        if (state) {
            // get the selected value
            var current_city = target.val();
            $.getJSON("/v1/moving_lead/get_cities/" + escape(state), function (json) {
                parse_and_inject_results(json, target, current_city);
                if (callback) {
                    callback();
                }
            });
        }
    }

    function load_zips(city, state, target) {
        if (city) {
            var current_zip = target.val();
            $.getJSON("/v1/moving_lead/get_zipcodes/" + escape(state) + "/" + escape(city), function (json) {
                parse_and_inject_results(json, target, current_zip);
            });
        }
    }

    function load_cities_and_zips(city, state, target) {
        var city_select = target.find("label:contains('City')").next();
        var state_code = state_code_from_name(state);
        if (city) {
            load_cities(state_code, city_select, function () {
                city_select.val(city);
                load_zips(city, state_code, target.find("label:contains('Zip')").next());
            });
        } else {
            load_cities(state_code, city_select);
        }
    }

    function parse_and_inject_results(json, target, current) {
        var data = json;
        var html = ['<option value="">Please select</option>'];
        var selected;

        current = current && current.toLowerCase().replace(' ', '');
        for (var i = 0, len = data.length; i < len; i++) {
            selected = (data[i].toLowerCase().replace(' ', '') == current ? ' selected="selected" ' : '');
            html.push('<option value="' + data[i] + '" ' + selected + '>' + data[i] + '</option>');
        }
        target.html(html.join(''));
    }

    function state_code_from_name(name) {
        return $("select#moving_lead_MovingTo_state").find('option').filter(
            function () {
                return (new RegExp('^' + name + '$')).test($(this).text());
            }).attr('value');
    }

    return {
        load_cities_and_zips: load_cities_and_zips,
        load_cities:          load_cities,
        load_zips:            load_zips
    };
});
/* 2012-04-26 11:13:21 -0400 */
