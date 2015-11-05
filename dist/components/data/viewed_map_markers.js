'use strict';
define(['jquery', 'flight/lib/component', 'map/components/mixins/stored_markers'], function($, defineComponent, storedMarkers) {
  var viewedMapMarkers;
  viewedMapMarkers = function() {
    this.record = function(ev, data) {
      var listingId;
      if (!data.gMarker.saveMarkerClick) {
        return;
      }
      listingId = data.gMarker.datum.id;
      return this.recordMarkerClick(listingId);
    };
    return this.after('initialize', function() {
      return this.on(document, 'markerClicked', this.record);
    });
  };
  return defineComponent(viewedMapMarkers, storedMarkers);
});
