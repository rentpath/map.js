var extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

define(['jquery'], function($) {
  return {
    "class": function() {
      return (function(superClass) {
        extend(_Class, superClass);

        function _Class(map) {
          this.map = map;
          this.mapDiv = $(this.map.getDiv());
        }

        _Class.prototype.container = $("<div/>", {
          "class": "hood_info_window"
        });

        _Class.prototype.addressBar = $('#address_search');

        _Class.prototype.listeners = [];

        _Class.prototype.offset = {
          x: 20,
          y: 20
        };

        _Class.prototype.draw = function() {
          var projection, px;
          projection = this.getProjection();
          if (!projection) {
            return;
          }
          px = projection.fromLatLngToDivPixel(this.position);
          if (!px) {
            return;
          }
          return this.container.css({
            left: this.getLeft(px),
            top: this.getTop(px)
          });
        };

        _Class.prototype.destroy = function() {
          this.setMap(null);
          return this.clearListeners();
        };

        _Class.prototype.onAdd = function() {
          return this.container.appendTo(this.getPanes().floatPane);
        };

        _Class.prototype.onRemove = function() {
          return this.container.hide();
        };

        _Class.prototype.setContent = function(html) {
          this.setMap(this.map);
          this.container.html(html);
          return this.show();
        };

        _Class.prototype.updatePosition = function(overlay) {
          return this.listeners.push(google.maps.event.addListener(overlay, "mousemove", (function(_this) {
            return function(event) {
              return _this.onMouseMove(event.latLng);
            };
          })(this)));
        };

        _Class.prototype.onMouseMove = function(latLng) {
          this.position = latLng;
          return this.draw();
        };

        _Class.prototype.hide = function() {
          this.container.hide().empty();
          return this.clearListeners();
        };

        _Class.prototype.show = function() {
          return this.container.show();
        };

        _Class.prototype.clearListeners = function() {
          var i, len, listener, ref, results;
          ref = this.listeners;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            listener = ref[i];
            results.push(google.maps.event.removeListener(listener));
          }
          return results;
        };

        _Class.prototype.getLeft = function(position) {
          var centerOffsetX, pos;
          centerOffsetX = this.mapRealCenter().x - this.mapCenter().x;
          pos = this.mapWidth() - position.x - this.container.outerWidth() - this.offset.x - centerOffsetX;
          if (pos < 0) {
            return this.mapWidth() - this.container.outerWidth() - this.offset.x - centerOffsetX;
          } else {
            return position.x + this.offset.x;
          }
        };

        _Class.prototype.getTop = function(position) {
          var addressBarHeight, bottom, centerOffsetY, height, isBottom, top;
          top = this.mapHeight() - position.y;
          height = this.container.outerHeight() + this.offset.y;
          centerOffsetY = Math.abs(this.mapRealCenter().y - this.mapCenter().y);
          addressBarHeight = (this.addressBar.outerHeight() || 0) + this.offset.y;
          bottom = this.mapHeight() - top - height - addressBarHeight - centerOffsetY;
          isBottom = bottom < 0;
          if (isBottom) {
            return centerOffsetY + addressBarHeight;
          } else {
            return this.mapHeight() - top - height;
          }
        };

        _Class.prototype.mapWidth = function() {
          return this.mapDiv.outerWidth();
        };

        _Class.prototype.mapHeight = function() {
          return this.mapDiv.outerHeight();
        };

        _Class.prototype.mapCenter = function() {
          return this.getProjection().fromLatLngToDivPixel(this.map.getCenter());
        };

        _Class.prototype.mapRealCenter = function() {
          return new google.maps.Point(this.mapWidth() / 2, this.mapHeight() / 2);
        };

        return _Class;

      })(google.maps.OverlayView);
    }
  };
});
