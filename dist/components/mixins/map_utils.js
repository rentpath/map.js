define(['jquery'], function($) {
  var mapUtils;
  mapUtils = function() {
    this.defaultAttrs({
      assetUrl: void 0,
      assetHostSelector: 'meta[name="asset_host"]',
      spinnerSelector: '.spinner',
      refinementsSelector: '.pageInfo[name="refinements"]',
      propertyNameParam: 'propertyname',
      mgtcoidParam: 'mgtcoid',
      propertyManagementRE: 'property-management'
    });
    this._extractParamFromUrl = function(key) {
      var i, len, param, queryParams, regex, value;
      queryParams = location.search.split('&') || [];
      regex = key + '=(.*)';
      for (i = 0, len = queryParams.length; i < len; i++) {
        param = queryParams[i];
        if (param.match(regex)) {
          value = param.match(regex);
        }
      }
      if (value) {
        return value[1] || '';
      }
    };
    this.limitScaleOf = function(number, limit) {
      if (limit == null) {
        limit = 4;
      }
      return number.toFixed(limit);
    };
    this.assetURL = function() {
      return this.attr.assetUrl || this.assetOriginFromMetaTag();
    };
    this.hideSpinner = function() {
      return $(this.attr.spinnerSelector).hide();
    };
    this.getMgtcoId = function(pathname) {
      if (pathname == null) {
        pathname = window.location.pathname;
      }
      return (pathname.match(this.attr.propertyManagementRE) && pathname.split('/')[5]) || this._extractParamFromUrl(this.attr.mgtcoidParam);
    };
    this.getRefinements = function() {
      return $(this.attr.refinementsSelector).attr("content") || '';
    };
    this.getPropertyName = function() {
      return this._extractParamFromUrl(this.attr.propertyNameParam);
    };
    this.getPriceRange = function(refinements) {
      var _ref, _ref1;
      _ref = _ref1 = void 0;
      return {
        min_price: ((_ref = refinements.min_price) != null ? _ref.value : void 0),
        max_price: ((_ref1 = refinements.max_price) != null ? _ref1.value : void 0)
      };
    };
    this.assetOriginFromMetaTag = function() {
      return $(this.attr.assetHostSelector).attr('content');
    };
  };
  return mapUtils;
});
