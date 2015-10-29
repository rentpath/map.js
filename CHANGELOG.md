# v1.2.0
* [feature] `MarkerClusterer` is now optional based on the result from the `shouldCluster` function. This allows apps to control when clustering is on. For enable, you can enable clustering based on the number of markers:

```coffee
Map
  markers:
    shouldCluster: (markers) ->
      markers.length > 200
```

[Compare v1.1.1..v1.2.0](https://github.com/RentPath/map.js/compare/v1.1.1...v1.2.0)
