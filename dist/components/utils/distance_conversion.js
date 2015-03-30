define([], function() {
  var distanceParamDefined, kmRatio, meterToKilometer, metersToKilometers, metersToMiles, milesToMeters;
  meterToKilometer = 1000;
  kmRatio = 0.62137;
  metersToKilometers = function(meters) {
    if (!distanceParamDefined(meters)) {
      return 0;
    }
    return (meters / meterToKilometer) * kmRatio;
  };
  milesToMeters = function(miles) {
    if (!distanceParamDefined(miles)) {
      return 0;
    }
    return (miles / kmRatio) * meterToKilometer;
  };
  metersToMiles = function(meters) {
    if (!distanceParamDefined(meters)) {
      return 0;
    }
    return (meters / meterToKilometer) * kmRatio;
  };
  distanceParamDefined = function(p) {
    return typeof p !== 'undefined' && p && p !== '';
  };
  return {
    convertMilesToMeters: function(miles) {
      return milesToMeters(miles);
    },
    convertMetersToKilometers: function(meters) {
      return metersToKilometers(meters);
    },
    convertMetersToMiles: function(meters) {
      return metersToMiles(meters);
    }
  };
});
