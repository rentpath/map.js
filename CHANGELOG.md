# v1.5.0
* [feature] When creating markers, you can pass in a function for `@attr.mapPin` and `@attr.mapPinShadow`. This allows the app to put conditional logic for different markers.
* [deprecated] Passing a string (url) to `@attr.mapPin` and `@attr.mapPinFree` is deprecated in favor of passing in a function. The intent is to move app logic out of map.js.

[Compare v1.4.1..v1.5.0](https://github.com/RentPath/map.js/compare/v1.4.1...v1.5.0)

# v1.4.1
* [bugfix] Remove unused methods and ensure that the event listeners that were intended to be removed (presumably to free memory) actually are.

[Compare v1.4.0..v1.4.1](https://github.com/RentPath/map.js/compare/v1.4.0...v1.4.1)

# v1.4.0
* [feature] Added 2 new events that are triggered on the document when a user interacts with a marker.
The events are: `markerMousedOver`, and `markerMousedOut`.

[Compare v1.3.0..v1.4.0](https://github.com/RentPath/map.js/compare/v1.3.0...v1.4.0)

# v1.3.0
* [feature] Added 3 new events that are triggered on the document when a user interacts with a marker cluster.
The events are: `markerClusterClick`, `markerClusterMouseOver`, and `markerClusterMouseOut`. The data payload for all of these events contains a single key `cluster` whose value is a reference to the `Cluster` object that the user interacted with.

[Compare v1.2.0..v1.3.0](https://github.com/RentPath/map.js/compare/v1.2.0...v1.3.0)

# v1.2.0
* [feature] `MarkerClusterer` is now optional based on the result from the `shouldCluster` function. This allows apps to control when clustering is on. For example, you can enable clustering based on the number of markers:

```coffee
Map
  markers:
    shouldCluster: (markers) ->
      markers.length > 200
```

[Compare v1.1.1..v1.2.0](https://github.com/RentPath/map.js/compare/v1.1.1...v1.2.0)
