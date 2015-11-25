'use strict';
define(['jquery', 'flight/lib/component'], function($, defineComponent) {
  var storedMarkers;
  return storedMarkers = function() {
    var store;
    store = void 0;
    this.defaultAttrs({
      storageKey: 'viewedMapMarkers'
    });
    this.localStorageSupported = function() {
      return typeof Storage !== "undefined" && Storage !== null;
    };
    this.load = function() {
      if (this.localStorageSupported()) {
        if (this.store == null) {
          this.store = JSON.parse(localStorage.getItem(this.attr.storageKey)) || {};
        }
      }
      return this.store;
    };
    this.save = function(values) {
      if (!this.localStorageSupported()) {
        return;
      }
      this.store = values;
      return localStorage.setItem(this.attr.storageKey, JSON.stringify(this.store));
    };
    this.storedMarkerExists = function(listingId) {
      return this.load()[listingId] != null;
    };
    return this.recordMarkerClick = function(listingId) {
      var viewedListingIds;
      viewedListingIds = this.load();
      if (viewedListingIds[listingId] == null) {
        viewedListingIds[listingId] = true;
        return this.save(viewedListingIds);
      }
    };
  };
});
