'use strict';
define(['jquery', 'flight/lib/component'], function($, defineComponent) {
  var storedMarkers;
  return storedMarkers = function() {
    this.defaultAttrs({
      storageKey: 'viewedMapMarkers'
    });
    this.load = function() {
      if (typeof Storage === "undefined" || Storage === null) {
        return {};
      }
      return JSON.parse(localStorage.getItem(this.attr.storageKey)) || {};
    };
    this.save = function(value) {
      if (typeof Storage === "undefined" || Storage === null) {
        return;
      }
      return localStorage.setItem(this.attr.storageKey, JSON.stringify(value));
    };
    this.storedMarkerExists = function(listingId) {
      return this.load()[listingId] != null;
    };
    return this.recordMarkerClick = function(listingId) {
      var viewedListingIds;
      viewedListingIds = this.load();
      if (viewedListingIds[listingId] != null) {
        return;
      }
      viewedListingIds[listingId] = true;
      return this.save(viewedListingIds);
    };
  };
});
