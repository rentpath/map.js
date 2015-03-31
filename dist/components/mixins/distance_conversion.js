define([], function() {
  var distanceConversion;
  distanceConversion = function() {
    var kmRatio, meterToKilometer;
    meterToKilometer = 1000;
    kmRatio = 0.62137;
    this._metersToKilometers = function(meters) {
      if (!this._distanceParamDefined(meters)) {
        return 0;
      }
      return (meters / meterToKilometer) * kmRatio;
    };
    this._milesToMeters = function(miles) {
      if (!this._distanceParamDefined(miles)) {
        return 0;
      }
      return (miles / kmRatio) * meterToKilometer;
    };
    this._metersToMiles = function(meters) {
      if (!this._distanceParamDefined(meters)) {
        return 0;
      }
      return (meters / meterToKilometer) * kmRatio;
    };
    this._distanceParamDefined = function(p) {
      return typeof p !== 'undefined' && p && p !== '';
    };
    this.convertMilesToMeters = function(miles) {
      return this._milesToMeters(miles);
    };
    this.convertMetersToKilometers = function(meters) {
      return this._metersToKilometers(meters);
    };
    return this.convertMetersToMiles = function(meters) {
      return this._metersToMiles(meters);
    };
  };
  return distanceConversion;
});
