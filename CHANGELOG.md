# v2.0.1
* [bugfix] Stored markers now keep a cache outside the components.
* [bugfix] Fix marker animation.

[Compare v2.0.0..v2.0.1](https://github.com/RentPath/map.js/compare/v2.0.0...v2.0.1)

# v2.0.0
* [breaking change] `uiMapZoom` and `uiMapCenter` will no longer fire if `uiMapZoomForListings` fires.
* [feature] `mixins/stored_markers` keeps a hash in memory (rather than parsing JSON when each marker is created).
* [feature] `ui/markers` re-uses existing markers rather than deleting all then adding all.
* [feature] Passing in a url rather than `{ url: 'url' }` as an icon is more performant (?!). This un-deprecates the feature.
* [deprecate] Remove `MarkerWithLabel` `MsFilter` attributes
* [deprecate] Remove unnecessary `MarkerWithLabel` global drag events
* [feature] Pass viewed state into `markerLabelOptions`

[Compare v1.12.0..v2.0.0](https://github.com/RentPath/map.js/compare/v1.12.0...v2.0.0)

# v1.12.0
* [feature] Add clusterFontFamily option

[Compare v1.11.0..v1.12.0](https://github.com/RentPath/map.js/compare/v1.11.0...v1.12.0)

# v1.11.0
* [feature] Attach refinements to pin URLs

[Compare v1.10.0..v1.11.0](https://github.com/RentPath/map.js/compare/v1.10.0...v1.11.0)

# v1.10.0
* [feature] Emit `uiMapZoom` and `uiMapCenter` events when zoom and/or center changes.

[Compare v1.9.2..v1.10.0](https://github.com/RentPath/map.js/compare/v1.9.2...v1.10.0)

# v1.9.2
* [update] Bump `marker-clusterer.js` to `v2.1.1.rp.1.0.3` (avoid animations that aren't visible)

[Compare v1.9.1..v1.9.2](https://github.com/RentPath/map.js/compare/v1.9.1...v1.9.2)

# v1.9.1
* [update] Bump `marker-clusterer.js` to `v2.1.1.rp.1.0.2` (off-by-one fix)

[Compare v1.9.0..v1.9.1](https://github.com/RentPath/map.js/compare/v1.9.0...v1.9.1)

# v1.9.0
* [feature] `markerClicked`, `markerMousedOver`, and `markerMousedOut` now send `viewed: true/false` in the event data.

[Compare v1.8.0..v1.9.0](https://github.com/RentPath/map.js/compare/v1.8.0...v1.9.0)

# v1.8.0
* [feature] Pass in `@attr.markerLabelOptions` which internally uses MarkerWithLabel. **Example:**
```coffee
    (datum) ->
      content: datum.price_range
      anchor:
        x: 27
        y: 28
        cssClass: 'my-map-pin-label'
```
* [feature] Add option to `data/listings` to limit number of pins. `@attr.pinLimit`
* [update] Bump `marker-clusterer.js` to `v2.1.1.rp.1.0.1`

[Compare v1.7.1..v1.8.0](https://github.com/RentPath/map.js/compare/v1.7.1...v1.8.0)

# v1.7.1
* [bugfix] Set marker clusterer averageCenter=true so that clusters are centered based on the avg position of the clustered markers instead of the position of the first marker clustered.

[Compare v1.7.0..v1.7.1](https://github.com/RentPath/map.js/compare/v1.7.0...v1.7.1)

# v1.7.0
* [feature] Add new options for decluster animation.

[Compare v1.6.1..v1.7.0](https://github.com/RentPath/map.js/compare/v1.6.1...v1.7.0)

# v1.6.1
* [optimization] Don't make data request when the current bounds are contained by the original bounbds.

[Compare v1.6.0..v1.6.1](https://github.com/RentPath/map.js/compare/v1.6.0...v1.6.1)

# v1.6.0
* [feature] Persist marker clicks to localStorage by saving the listing id.

The default is off and the app must set saveMarkerClick to true
in the markers options to enable it.

[Compare v1.5.1..v1.6.0](https://github.com/RentPath/map.js/compare/v1.5.1...v1.6.0)

# v1.5.1
* [optimization] Don't make data request when zooming in.
  Was making request when zooming in or out, but we really only need to make the request when zooming out.

[Compare v1.5.0..v1.5.1](https://github.com/RentPath/map.js/compare/v1.5.0...v1.5.1)

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
