(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  define(["jquery"], function($) {
    return window.GeoLocator = (function() {

      function GeoLocator() {
        this.makeUrl = __bind(this.makeUrl, this);

        this.processGeoDataResponse = __bind(this.processGeoDataResponse, this);

        this.handleError = __bind(this.handleError, this);

        this.handleClickSuccess = __bind(this.handleClickSuccess, this);

        this.handleLocationSuccess = __bind(this.handleLocationSuccess, this);

        var geoSearchDiv,
          _this = this;
        this.lat = 0;
        this.lng = 0;
        geoSearchDiv = $('#geo_search_box');
        if (navigator.geolocation) {
          geoSearchDiv.show();
          geoSearchDiv.find('a').bind('click', function(e) {
            return _this.getLocation(_this.handleClickSuccess, _this.handleError);
          });
        }
        return;
      }

      GeoLocator.prototype.setCoordinates = function(callback) {
        var successFx, that;
        that = this;
        successFx = function(position) {
          that.handleLocationSuccess(position);
          callback();
        };
        this.getLocation(successFx, this.handleError);
      };

      GeoLocator.prototype.getLocation = function(success, error) {
        var curr_position;
        if (navigator && navigator.geolocation) {
          curr_position = navigator.geolocation.getCurrentPosition(success, error);
        } else {
          this.resizeHome();
        }
      };

      GeoLocator.prototype.handleLocationSuccess = function(position) {
        this.lat = position.coords.latitude;
        this.lng = position.coords.longitude;
      };

      GeoLocator.prototype.handleClickSuccess = function(position) {
        this.handleLocationSuccess(position);
        if (this.lat && this.lng) {
          window.location = "/geolocation/" + this.lat + "/" + this.lng + "/";
        }
      };

      GeoLocator.prototype.handleError = function(error) {
        alert('Unable to determine your current location');
      };

      GeoLocator.prototype.resizeHome = function() {
        var $container, $container_height, $download_link, $header_height, $html_height, default_image, newHeight;
        $container = $('.home_lead');
        default_image = "<img src='images/stock_lead.jpg' alt='default_image' />";
        $html_height = $("html").height();
        $download_link = $("#downloadLink").height();
        $header_height = $("#header").height();
        $container_height = $container.height();
        $container.html(default_image);
        newHeight = $html_height - $download_link - $header_height - $container_height + "px";
        return $(".leadHeight").css("height", newHeight);
      };

      GeoLocator.prototype.getGeoDataFromMeta = function(options) {
        var $deferred, url, urlOptions,
          _this = this;
        $deferred = new $.Deferred();
        urlOptions = (options != null) && (options.urlParameters != null) ? this.makeUrl(options.urlParameters) : '';
        url = '/meta/geo' + urlOptions;
        $.when(this.fetchData(url)).done(function(response) {
          var geoDataResponse;
          geoDataResponse = _this.processGeoDataResponse(response);
          return $deferred.resolve(geoDataResponse);
        }).fail(function(response) {
          return $deferred.reject(response);
        });
        return $deferred.promise();
      };

      GeoLocator.prototype.processGeoDataResponse = function(response) {
        var geoDataResponse;
        geoDataResponse = {};
        if (response.status) {
          $.extend(geoDataResponse, response);
        } else {
          if (response && response.lat && response.lng && response.city && response.state) {
            $.extend(geoDataResponse, {
              lat: response.lat,
              lng: response.lng,
              city: response.city,
              state: response.state
            });
          }
        }
        return geoDataResponse;
      };

      GeoLocator.prototype.makeUrl = function(params) {
        var firstTime, url;
        url = "";
        firstTime = true;
        _.each(params, function(k, v) {
          if (v != null) {
            url += firstTime != null ? firstTime : {
              '?': '&'
            };
            firstTime = false;
            return url += "" + k + "=" + (v != null ? {
              v: ''
            } : void 0);
          }
        });
        return url;
      };

      GeoLocator.prototype.fetchData = function(url) {
        return $.ajax({
          url: url
        });
      };

      return GeoLocator;

    })();
  });

}).call(this);
