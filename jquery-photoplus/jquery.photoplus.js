define(['jquery'], function ($) {

    (function ($) {
        $.fn.photoplus = function () {
            var Slide = {
                sliders:{},
                loaded:[],
                image_width:140,

                store_info:function (anchor_id, image_paths, href_val, result_id) {

                    var block_info = [];
                    block_info.push(anchor_id);
                    block_info.push(image_paths);
                    block_info.push(href_val);
                    block_info.push(result_id);
                    this.sliders[result_id] = block_info;
                },

                setup_gallery:function (ev) {
                    var process = false;
                    if ($.inArray(ev.data.result_id, Slide.loaded) == -1) {
                        var slide = Slide.sliders[ev.data.result_id],
                            paths_array = slide[1]['photo_urls'],
                            href_val = slide[2],
                            anchor_id = slide[0],
                            array_width = (paths_array.length * Slide.image_width) + 'px',
                            photo_anchor = $(this).find('.scrollableArea');
                        paths_array.shift();

                        $(this).find('.scrollableArea').width(array_width);

                        $(paths_array).each(function () {
                            slide_tag = "<a ";
                            slide_tag += "href='" + href_val + "'>";
                            slide_tag += "<img ";
                            slide_tag += "src='http://image.apartmentguide.com" + this;
                            slide_tag += "' width='140px'";
                            slide_tag += " height='105px'";
                            slide_tag += ">";
                            slide_tag += "</a>";
                            photo_anchor.append(slide_tag);
                        });
                        Slide.loaded[Slide.loaded.length] = ev.data.result_id;

                        $(this).find('.scrollingHotSpotRight').on('click', function () {
                            if ( !process ){
                                var rightHotSpot = $(this).parent().next().find('.scrollableArea'),
                                    leftPos = Math.abs(rightHotSpot.position().left);
                                if (rightHotSpot.width() - Math.abs(rightHotSpot.position().left) > Slide.image_width) {
                                    process = true;
                                    rightHotSpot.animate({
                                        right: '+=140px'
                                    }, 400, function () {
                                        var image_num = Math.abs(rightHotSpot.position().left) / Slide.image_width + 1,
                                            image_total = rightHotSpot.width() / Slide.image_width,
                                            image_counter = $(this).parentsUntil('.column1').find('.scroll_image_counter');
                                        image_counter.html(image_num + '/' + image_total);
                                        process = false;
                                    });
                                }
                            }
                        });

                        $(this).find('.scrollingHotSpotLeft').on('click', function () {
                            if ( !process ){
                                var leftHotSpot = $(this).parent().next().find('.scrollableArea');
                                if (leftHotSpot.position().left < 0) {
                                    process = true;
                                    leftHotSpot.animate({
                                        right:'-=140px'
                                    }, 400, function () {
                                        var image_num = Math.abs(leftHotSpot.position().left) / Slide.image_width + 1,
                                            image_total = leftHotSpot.width() / Slide.image_width,
                                            image_counter = $(this).parentsUntil('.column1').find('.scroll_image_counter');
                                        image_counter.html(image_num + '/' + image_total);
                                        process = false;
                                    });
                                }
                            }
                        });
                    }
                }
            };

            return $(this).each(function () {
                var anchor_id = $(this).attr('id'),
                    image_paths = $(this).data('photoplus'),
                    href_val = $(this).find('a').attr('href'),
                    result_id = $(this).closest('.result').attr('id'),
                    photo_size = image_paths['photo_urls'].length;
                Slide.store_info(anchor_id, image_paths, href_val, result_id);
                $(this).closest('.result').on('mouseenter', {result_id:result_id}, Slide.setup_gallery);
                $(this).find('.scroll_image_counter').html('1/' + image_paths['photo_urls'].length);
            });
        };
    })(jQuery);
});
/* 2012-04-26 11:13:21 -0400 */
