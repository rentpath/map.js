define [], () ->

  meterToKilometer = 1000
  kmRatio = 0.62137

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
      milesToMeters(miles)

    convertMetersToKilometers: (meters) ->
      metersToKilometers(meters)

    convertMetersToMiles: (meters) ->
      metersToMiles(meters)
  }