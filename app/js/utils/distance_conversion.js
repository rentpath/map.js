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

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbInV0aWxzL2Rpc3RhbmNlX2NvbnZlcnNpb24uY29mZmVlIl0sIm5hbWVzIjpbXSwibWFwcGluZ3MiOiJBQUFBLE1BQUEsQ0FBTyxFQUFQLEVBQVcsU0FBQSxHQUFBO0FBRVQsTUFBQSxpR0FBQTtBQUFBLEVBQUEsZ0JBQUEsR0FBbUIsSUFBbkIsQ0FBQTtBQUFBLEVBQ0EsT0FBQSxHQUFVLE9BRFYsQ0FBQTtBQUFBLEVBR0Esa0JBQUEsR0FBcUIsU0FBQyxNQUFELEdBQUE7QUFDbkIsSUFBQSxJQUFBLENBQUEsb0JBQWdCLENBQXFCLE1BQXJCLENBQWhCO0FBQUEsYUFBTyxDQUFQLENBQUE7S0FBQTtXQUNBLENBQUMsTUFBQSxHQUFTLGdCQUFWLENBQUEsR0FBOEIsUUFGWDtFQUFBLENBSHJCLENBQUE7QUFBQSxFQU9BLGFBQUEsR0FBZ0IsU0FBQyxLQUFELEdBQUE7QUFDZCxJQUFBLElBQUEsQ0FBQSxvQkFBZ0IsQ0FBcUIsS0FBckIsQ0FBaEI7QUFBQSxhQUFPLENBQVAsQ0FBQTtLQUFBO1dBQ0EsQ0FBQyxLQUFBLEdBQVEsT0FBVCxDQUFBLEdBQW9CLGlCQUZOO0VBQUEsQ0FQaEIsQ0FBQTtBQUFBLEVBV0EsYUFBQSxHQUFnQixTQUFDLE1BQUQsR0FBQTtBQUNkLElBQUEsSUFBQSxDQUFBLG9CQUFnQixDQUFxQixNQUFyQixDQUFoQjtBQUFBLGFBQU8sQ0FBUCxDQUFBO0tBQUE7V0FDQSxDQUFDLE1BQUEsR0FBUyxnQkFBVixDQUFBLEdBQThCLFFBRmhCO0VBQUEsQ0FYaEIsQ0FBQTtBQUFBLEVBZUEsb0JBQUEsR0FBdUIsU0FBQyxDQUFELEdBQUE7V0FDckIsTUFBQSxDQUFBLENBQUEsS0FBWSxXQUFaLElBQTJCLENBQTNCLElBQWdDLENBQUEsS0FBSyxHQURoQjtFQUFBLENBZnZCLENBQUE7QUFrQkEsU0FBTztBQUFBLElBQ0wsb0JBQUEsRUFBc0IsU0FBQyxLQUFELEdBQUE7YUFDcEIsYUFBQSxDQUFjLEtBQWQsRUFEb0I7SUFBQSxDQURqQjtBQUFBLElBSUwseUJBQUEsRUFBMkIsU0FBQyxNQUFELEdBQUE7YUFDekIsa0JBQUEsQ0FBbUIsTUFBbkIsRUFEeUI7SUFBQSxDQUp0QjtBQUFBLElBT0wsb0JBQUEsRUFBc0IsU0FBQyxNQUFELEdBQUE7YUFDcEIsYUFBQSxDQUFjLE1BQWQsRUFEb0I7SUFBQSxDQVBqQjtHQUFQLENBcEJTO0FBQUEsQ0FBWCxDQUFBLENBQUEiLCJmaWxlIjoidXRpbHMvZGlzdGFuY2VfY29udmVyc2lvbi5qcyIsInNvdXJjZVJvb3QiOiIvc291cmNlLyIsInNvdXJjZXNDb250ZW50IjpbImRlZmluZSBbXSwgKCkgLT5cblxuICBtZXRlclRvS2lsb21ldGVyID0gMTAwMFxuICBrbVJhdGlvID0gMC42MjEzN1xuXG4gIG1ldGVyc1RvS2lsb21ldGVycyA9IChtZXRlcnMpIC0+XG4gICAgcmV0dXJuIDAgdW5sZXNzIGRpc3RhbmNlUGFyYW1EZWZpbmVkKG1ldGVycylcbiAgICAobWV0ZXJzIC8gbWV0ZXJUb0tpbG9tZXRlcikgKiBrbVJhdGlvXG5cbiAgbWlsZXNUb01ldGVycyA9IChtaWxlcykgLT5cbiAgICByZXR1cm4gMCB1bmxlc3MgZGlzdGFuY2VQYXJhbURlZmluZWQobWlsZXMpXG4gICAgKG1pbGVzIC8ga21SYXRpbykgKiBtZXRlclRvS2lsb21ldGVyXG5cbiAgbWV0ZXJzVG9NaWxlcyA9IChtZXRlcnMpIC0+XG4gICAgcmV0dXJuIDAgdW5sZXNzIGRpc3RhbmNlUGFyYW1EZWZpbmVkKG1ldGVycylcbiAgICAobWV0ZXJzIC8gbWV0ZXJUb0tpbG9tZXRlcikgKiBrbVJhdGlvXG5cbiAgZGlzdGFuY2VQYXJhbURlZmluZWQgPSAocCkgLT5cbiAgICB0eXBlb2YgcCAhPSAndW5kZWZpbmVkJyAmJiBwICYmIHAgIT0gJydcblxuICByZXR1cm4ge1xuICAgIGNvbnZlcnRNaWxlc1RvTWV0ZXJzOiAobWlsZXMpIC0+XG4gICAgICBtaWxlc1RvTWV0ZXJzKG1pbGVzKVxuXG4gICAgY29udmVydE1ldGVyc1RvS2lsb21ldGVyczogKG1ldGVycykgLT5cbiAgICAgIG1ldGVyc1RvS2lsb21ldGVycyhtZXRlcnMpXG5cbiAgICBjb252ZXJ0TWV0ZXJzVG9NaWxlczogKG1ldGVycykgLT5cbiAgICAgIG1ldGVyc1RvTWlsZXMobWV0ZXJzKVxuICB9Il19