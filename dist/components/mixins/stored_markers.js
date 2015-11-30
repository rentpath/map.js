'use strict';
define(['jquery', 'flight/lib/component'], function($, defineComponent) {
  var store, storedMarkers;
  store = void 0;
  return storedMarkers = function() {
    this.defaultAttrs({
      storageKey: 'viewedMapMarkers'
    });
    this.localStorageSupported = function() {
      return typeof Storage !== "undefined" && Storage !== null;
    };
    this.load = function() {
      if (this.localStorageSupported()) {
        if (store == null) {
          store = JSON.parse(localStorage.getItem(this.attr.storageKey)) || {};
        }
      }
      return store;
    };
    this.save = function(values) {
      if (!this.localStorageSupported()) {
        return;
      }
      store = values;
      return localStorage.setItem(this.attr.storageKey, JSON.stringify(store));
    };
    this.storedMarkerExists = function(listingId) {
      return this.load()[listingId] != null;
    };
    this.recordMarkerClick = function(listingId) {
      var viewedListingIds;
      viewedListingIds = this.load();
      if (viewedListingIds[listingId] == null) {
        viewedListingIds[listingId] = true;
        return this.save(viewedListingIds);
      }
    };
    return this.reset = function() {
      store = void 0;
      return localStorage.removeItem(this.attr.storageKey);
    };
  };
});
