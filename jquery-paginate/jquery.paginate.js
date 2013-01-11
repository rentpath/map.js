define(['jquery'], function ($) {

    (function ($) {
        $.fn.paginate = function (options) {

            var body = "", defaults = {
                    totalPages:10,
                    step:5,
                    indexUpdated:$.noop,
                    itemSelector:"",
                    initialIndex: (options.initialIndex || 1)
                },
                parameters = $.extend({}, defaults, options),
                $target = $(parameters.target),
                CURRENT_POSITION_CLASS = "currentPosition";

            $target.find('ol').remove();

            if( parameters.totalPages == 0 ){
                return;
            }else if (parameters.totalPages < parameters.step) {
                parameters.step = parameters.totalPages;
            }

            var element = function (number) {
                return "<li data-index=\"" + number + "\">" + number + "</li>";
            };

            var renderPageNumbers;
            body += (renderPageNumbers = function(total, step, index) {
              var body = '';

              var pagingIndex = (index > (total - step + 1) ? index - (index - (total - step + 1) ) : index);
              var i;
              for (i = 0; i < step; i++) {
                  body += element(i + pagingIndex);
              }
              return body;
            })(parameters.totalPages, parameters.step, parameters.initialIndex);


            $target.unbind('click');
            $target.append("<ol><li class='first sprite' style=\"display:none\"></li><li class='prev sprite' style=\"display:none\"></li>" + body + "<li class='next sprite'></li><li class='last sprite'></li></ol>");

            var midElementIndex = Math.ceil(parameters.step / 2) - 1; // middle of range

            var moveTo = function(element){
                var $current = $(element);
                if (canCenterElement($current)) {
                    var selectedElementIndex = -1;
                    $.each($target.find('li[data-index]'), function (index, value) {
                        if ($(value).data().index == $current.data().index) {
                            selectedElementIndex = index;
                            return false;
                        }
                    });

                    if (midElementIndex <= selectedElementIndex) { //Everything left and equal to the middle index
                        (function () {
                            var offset = selectedElementIndex - midElementIndex;
                            var availableElements = parameters.totalPages - $current.data().index;
                            if (availableElements >= offset) {
                                var i = 0;
                                for (i; i < offset; i++) {
                                    moveElementsRight();
                                }
                            }
                            $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                            setCurrentPosition($current);

                        })();
                    } else {// Everything right of the middle index
                        (function () {
                            var offset = midElementIndex - selectedElementIndex;
                            var availableElements = $current.data().index - 1;
                            if (availableElements >= offset) {
                                var i = 0;
                                for (i; i < offset; i++) {
                                    moveElementsLeft();
                                }
                            }
                            $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                            setCurrentPosition($current);
                        })();
                    }
                    updateControls($current);

                } else if ($current.data().index == parameters.totalPages - 1 && $current.next().data().index == undefined) {// element is 2nd to last
                    moveElementsRight();
                    $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                    setCurrentPosition($current);
                    updateControls($current);
                } else if ($current.data().index == 2 && $current.prev().data().index == undefined) { //2nd element
                    moveElementsLeft();
                    $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                    setCurrentPosition($current);
                } else {
                    $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                    setCurrentPosition($current);
                    updateControls($current);
                }
            };


            var canShiftLeft = function (element) {
                return $(element).data().index != 1;
            };

            var canShiftRight = function (element) {
                return $(element).data().index != parameters.totalPages;
            };

            var moveElementsRight = function () {
                $($target.find('li[data-index]:first').remove());
                $($target.find('li[data-index]:last').after(element($target.find('li[data-index]:last').data().index + 1)));
            };

            var moveElementsLeft = function () {
                $($target.find('li[data-index]:last').remove());
                $($target.find('li[data-index]:first').before(element($target.find('li[data-index]:first').data().index - 1)));
            };


            var $prev = $($target.find('li.prev'));
            var $first = $($target.find('li.first'));
            var $next = $($target.find('li.next'));
            var $last = $($target.find('li.last'));

            var updateControls = function (current) {
                $prev.toggle($(current).data().index != 1);
                $first.toggle($(current).data().index != 1);
                $next.toggle($(current).data().index != parameters.totalPages);
                $last.toggle($(current).data().index != parameters.totalPages);
            };

            var setCurrentPosition = function (current) {
                $target.find("." + CURRENT_POSITION_CLASS).removeClass(CURRENT_POSITION_CLASS);
                $(current).addClass(CURRENT_POSITION_CLASS);
            };


            var canCenterElement = function (current) {
                var $current = current;
                if ($(current).data().index - 1 < midElementIndex) {
                    return false;
                }
                var selectedElementIndex = -1;
                var availableElements = parameters.totalPages - $current.data().index;
                $.each($target.find('li[data-index]'), function (index, value) {
                    if ($(value).data().index == $current.data().index) {
                        selectedElementIndex = index;
                        return false;
                    }
                });
                var offset = selectedElementIndex - midElementIndex;
                return offset <= availableElements && availableElements >= (parameters.step - 1) - midElementIndex;

            };


            $target.on('click', 'li[data-index]', function () {
                parameters.indexUpdated($(this).data().index);
                moveTo($(this));  // A. J. -- Check this out later
               /* updateContent($(this).data().index);*/
            });

            $prev.click(function () {
                var $current = $($target.find("." + CURRENT_POSITION_CLASS));

                if (canShiftLeft($current)) { //not at the end
                    if ($target.find('li[data-index]:first').data().index != 1 && $current.data().index - 1 < parameters.totalPages - midElementIndex) {
                        moveElementsLeft();
                    }
                    $current = $current.prev();
                    parameters.indexUpdated($current.data().index);
                    setCurrentPosition($current);parameters.indexUpdated($current.data().index);
                }
                updateControls($current);

                /*updateContent($current.data().index);*/
            });

            $next.click(function () {
                var $current = $($target.find("." + CURRENT_POSITION_CLASS));

                if (canShiftRight($current)) {
                    if ($current.data().index > midElementIndex && $target.find('li[data-index]:last').data().index != parameters.totalPages) { // if we can just grab the next without adding and removing
                        moveElementsRight();
                    }
                    $current = $current.next();
                    parameters.indexUpdated($current.data().index);
                    setCurrentPosition($current);
                }
                updateControls($current);

                /*updateContent($current.data().index);*/
            });

            $first.click(function () {
                $target.find('li[data-index]').remove();
                var $current = $(element(1));
                parameters.indexUpdated($current.data().index);
                $prev.after($current);
                $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                setCurrentPosition($current);
                var i = 0;
                for (i; i < parameters.step - 1; i++) {
                    var first = $target.find('li[data-index]:last');
                    first.after(element(first.data().index + 1));
                }
                updateControls($current);

                /*updateContent($current.data().index);*/
            });

            $last.click(function () {
                $target.find('li[data-index]').remove();
                var $current = $(element(parameters.totalPages));
                parameters.indexUpdated($current.data().index);
                $next.before($current);
                $current = $target.find('li[data-index=\"' + $current.data().index + '\"]');
                setCurrentPosition($current);
                var i = 0;
                for (i; i < parameters.step - 1; i++) {
                    var first = $target.find('li[data-index]:first');
                    first.before(element(first.data().index - 1));
                }
                updateControls($current);

               /* updateContent($current.data().index);*/

            });

            var initialElement = function(i){
              return 'li[data-index=' + i + ']';
            };

            moveTo($(initialElement(parameters.initialIndex)));

        };
    })(jQuery);
});
/* 2012-04-26 11:13:21 -0400 */
