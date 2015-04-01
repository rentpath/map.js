define [ ], () ->

  distanceConversion = ->
    meterToKilometer = 1000
    kmRatio = 0.62137

    @_metersToKilometers = (meters) ->
      return 0 unless meters
      (meters / meterToKilometer) * kmRatio

    @_milesToMeters = (miles) ->
      return 0 unless miles
      (miles / kmRatio) * meterToKilometer

    @_metersToMiles = (meters) ->
      return 0 unless meters
      (meters / meterToKilometer) * kmRatio

    @convertMilesToMeters = (miles) ->
      @_milesToMeters(miles)

    @convertMetersToKilometers = (meters) ->
      @_metersToKilometers(meters)

    @convertMetersToMiles = (meters) ->
      @_metersToMiles(meters)

  return distanceConversion
