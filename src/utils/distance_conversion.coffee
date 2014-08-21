define [], () ->

  meterToKilometer = 1000
  kmRatio = 0.62137
  decimalLimit = 4

  metersToKilometers = (meters) ->
    return 0 unless distanceParamDefined(meters)
    (meters / meterToKilometer) * kmRatio

  milesToMeters = (miles) ->
    return 0 unless distanceParamDefined(miles)
    (miles / kmRatio) * meterToKilometer

  metersToMiles = (meters) ->
    return 0 unless distanceParamDefined(meters)
    (meters / meterToKilometer) * kmRatio

  distanceParamDefined = (p) ->
    typeof p != 'undefined' && p && p != ''

  return {
    convertMilesToMeters: (miles) ->
      milesToMeters(miles).toFixed(decimalLimit)

    convertMetersToKilometers: (meters) ->
      metersToKilometers(meters).toFixed(decimalLimit)

    convertMetersToMiles: (meters) ->
      metersToMiles(meters).toFixed(decimalLimit)
  }