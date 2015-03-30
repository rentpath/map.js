define(['jquery', 'es5-shim', 'es5-sham', 'flight/lib/utils', 'map/ui/base_map', 'map/ui/markers_info_window'], function($, es5Shim, es5Sham, FlightUtils, BaseMap, MarkerInfoWindow) {
  var initialize;
  initialize = function() {
    var args;
    args = arguments[0];
    BaseMap.attachTo(args.map.canvas, args.map);
    return MarkerInfoWindow.attachTo(args.map.canvas, args.markers);
  };
  return initialize;
});

//# sourceMappingURL=data:application/json;base64,eyJ2ZXJzaW9uIjozLCJzb3VyY2VzIjpbIm1hcC5jb2ZmZWUiXSwibmFtZXMiOltdLCJtYXBwaW5ncyI6IkFBQUEsTUFBQSxDQUFPLENBQ0wsUUFESyxFQUVMLFVBRkssRUFHTCxVQUhLLEVBSUwsa0JBSkssRUFLTCxpQkFMSyxFQU1MLDRCQU5LLENBQVAsRUFPRyxTQUNELENBREMsRUFFRCxPQUZDLEVBR0QsT0FIQyxFQUlELFdBSkMsRUFLRCxPQUxDLEVBTUQsZ0JBTkMsR0FBQTtBQW9CRCxNQUFBLFVBQUE7QUFBQSxFQUFBLFVBQUEsR0FBYSxTQUFBLEdBQUE7QUFDWCxRQUFBLElBQUE7QUFBQSxJQUFBLElBQUEsR0FBTyxTQUFVLENBQUEsQ0FBQSxDQUFqQixDQUFBO0FBQUEsSUFFQSxPQUFPLENBQUMsUUFBUixDQUFpQixJQUFJLENBQUMsR0FBRyxDQUFDLE1BQTFCLEVBQWtDLElBQUksQ0FBQyxHQUF2QyxDQUZBLENBQUE7V0FHQSxnQkFBZ0IsQ0FBQyxRQUFqQixDQUEwQixJQUFJLENBQUMsR0FBRyxDQUFDLE1BQW5DLEVBQTJDLElBQUksQ0FBQyxPQUFoRCxFQUpXO0VBQUEsQ0FBYixDQUFBO0FBTUEsU0FBTyxVQUFQLENBMUJDO0FBQUEsQ0FQSCxDQUFBLENBQUEiLCJmaWxlIjoibWFwLmpzIiwic291cmNlUm9vdCI6Ii9zb3VyY2UvIiwic291cmNlc0NvbnRlbnQiOlsiZGVmaW5lIFtcbiAgJ2pxdWVyeSdcbiAgJ2VzNS1zaGltJ1xuICAnZXM1LXNoYW0nXG4gICdmbGlnaHQvbGliL3V0aWxzJ1xuICAnbWFwL3VpL2Jhc2VfbWFwJ1xuICAnbWFwL3VpL21hcmtlcnNfaW5mb193aW5kb3cnXG5dLCAoXG4gICRcbiAgZXM1U2hpbVxuICBlczVTaGFtXG4gIEZsaWdodFV0aWxzXG4gIEJhc2VNYXBcbiAgTWFya2VySW5mb1dpbmRvd1xuKSAtPlxuXG4gICMgRVhQRUNURUQgQVJHVU1FTlRTXG4gICMgRmlyc3QgZWxlbWVudCBpcyBhbiBvcHRpb25zIG9iamVjdCwgc2FtcGxlIGJlbG93XG4gICMgQWRkIG1vcmUgb3B0aW9ucyBhcyBuZWVkZWRcblxuICAjIG1hcDpcbiAgIyAgIGdlb0RhdGE6IGdlb0RhdGFcbiAgIyAgIGNhbnZhczogJyNtYXBfY2FudmFzJ1xuICAjICAgZ01hcE9wdGlvbnM6XG4gICMgICAgIGRyYWdnYWJsZTogZmFsc2VcbiAgIyBoeWJyaWRMaXN0OiB1bmRlZmluZWRcblxuICBpbml0aWFsaXplID0gLT5cbiAgICBhcmdzID0gYXJndW1lbnRzWzBdXG5cbiAgICBCYXNlTWFwLmF0dGFjaFRvKGFyZ3MubWFwLmNhbnZhcywgYXJncy5tYXApXG4gICAgTWFya2VySW5mb1dpbmRvdy5hdHRhY2hUbyhhcmdzLm1hcC5jYW52YXMsIGFyZ3MubWFya2VycylcblxuICByZXR1cm4gaW5pdGlhbGl6ZVxuIl19