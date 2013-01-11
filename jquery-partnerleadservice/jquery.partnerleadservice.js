define(['jquery'], function ($) {

    (function ($) {
        $.fn.partnerLeadService = function (options) {

            var form_div = $(this);

            var formLoad = function () {
                url = buildNewUrl(opts.form_params);
                form_div.load(url, function () {
                    opts.update_form();
                    $('.partner_lead_form', form_div).submit(submitLead);
                    form_div.show();
                });
            };


            var buildNewUrl = function (params) {
                var base = '/v2/partner_leads/new?';
                var uri = '';

                $.each(params.required_fields, function(k,v){
                    uri += "partner_lead[required_fields][]=" + v + "&";
                });
                delete params.required_fields;

                $.each(params, function(k, v) {
                    uri += "partner_lead[" + k + "]=" + v + "&";
                });

                uri = uri.substring(0, uri.length - 1);
                base += encodeURI(uri);
                return base;
            };

            var submitLead = function () {
                var caller = $(this);
                if (this.beenSubmitted) {
                    return false;
                }
                this.beenSubmitted = true;

                $.ajax({
                    url:'/v2/partner_leads/ajax.js',
                    type:'POST',
                    data:$(this).serialize(),
                    success:function (response) {
                        opts.lead_saved();
                    },
                    error:function (req, status, err) {
                        var parent = caller.parent();
                        caller.replaceWith(req.responseText);
                        opts.update_form();
                        $('.partner_lead_form', parent).submit(submitLead);
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

            return this.each(function () {
                formLoad();
            });

        };
    })(jQuery);

});
/* 2012-04-26 11:13:21 -0400 */
