define(['jquery'], function($) {
  var _extractParamFromUrl;
  _extractParamFromUrl = function(key) {
    var param, queryParams, regex, value, _i, _len;
    queryParams = location.search.split('&') || [];
    regex = key + '=(.*)';
    for (_i = 0, _len = queryParams.length; _i < _len; _i++) {
      param = queryParams[_i];
      if (param.match(regex)) {
        value = param.match(regex);
      }
    }
    if (value) {
      return value[1] || '';
    }
  };
  return {
    limitScaleOf: function(number, limit) {
      if (limit == null) {
        limit = 4;
      }
      return number.toFixed(limit);
    },
    assetURL: function() {
      return $('meta[name="asset_host"]').attr('content');
    },
    hideSpinner: function() {
      return $('.spinner').hide();
    },
    getMgtcoId: function(pathname) {
      if (pathname == null) {
        pathname = window.location.pathname;
      }
      return (pathname.match('property-management') && pathname.split('/')[5]) || _extractParamFromUrl('mgtcoid');
    },
    getRefinements: function() {
      return $(".pageInfo[name=refinements]").attr("content") || '';
    },
    getPropertyName: function() {
      return _extractParamFromUrl('propertyname');
    },
    getPriceRange: function(refinements) {
      var _ref, _ref1;
      _ref = _ref1 = void 0;
      return {
        min_price: ((_ref = refinements.min_price) != null ? _ref.value : void 0),
        max_price: ((_ref1 = refinements.max_price) != null ? _ref1.value : void 0)
      };
    }
  };
});
