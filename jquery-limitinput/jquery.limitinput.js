define(function() {
    (function ($) {
        $.fn.limit_input = function(limit, original_label){
          var self = $(this);
          var label = self.siblings('label');
          var update_span = $('<span></span>');
          var left = limit;

          label.html(original_label + ' ').append(update_span);
          self.blur(function(){ update_span.html(''); });

          self.keyup(function(){
            left = limit - self.val().length;
            if( left < 0 ){ left = 0; self.val(self.val().substring(0, limit)); }
            update_span.html('(limit ' + limit + ', ' + left + ' left)');
          });
        };
    })(jQuery);
})
