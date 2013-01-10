define(['jquery'], function ($) {
    $.fn.caesar = function(options) {
      var opts = $.extend($.fn.caesar.defaults, options);

      return this.each(function() {
        var self, encoded, decoded = "";
        self = $(this);
        encoded = self.attr(opts.attr) || "";
        for(i = 0; i < encoded.length; i++) {
          decoded += opts.charLookup[encoded[i]] || encoded[i];
        }
        self.bind('click', {
          decoded: decoded, 
          encoded: encoded
        }, opts.onClick);
      });
    };

    $.fn.caesar.defaults = {
      attr: "data-href",
      charLookup: {
        a: "z", b: "a", c: "b", d: "c", e: "d", f: "e", g: "f", h: "g", i: "h", j: "i",
        k: "j", l: "k", m: "l", n: "m", o: "n", p: "o", q: "p", r: "q", s: "r", t: "s",
        u: "t", v: "u", w: "v", x: "w", y: "x", z: "y", 1: "0", 2: "1", 3: "2", 4: "3",
        5: "4", 6: "5", 7: "6", 8: "7", 9: "8", 0: "9"
      },
      onClick: function(e) {
        $(this).data("target") == "_blank" ? window.open(e.data.decoded, "_blank") : window.location = e.data.decoded;
      }
    }
});
