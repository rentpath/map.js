'use strict';
define(['jquery', 'underscore', 'flight/lib/component', 'map/components/mixins/mobile_detection', 'map/components/ui/tool_tip'], function($, _, defineComponent, mobileDetection, toolTip) {
  var neighborhoodsOverlay;
  _.templateSettings = {
    interpolate: /\{\{(.+?)\}\}/g,
    evaluate: /<%(.+?)%>/g
  };
  neighborhoodsOverlay = function() {
    this.defaultAttrs({
      fusionApiUrl: "https://www.googleapis.com/fusiontables/v1/query?sql=",
      baseInfoHtml: "<strong>Neighborhood: </strong>{{hood}}",
      enableOnboardCalls: false,
      enableMouseover: false,
      tableId: void 0,
      apiKey: void 0,
      gMap: void 0,
      data: void 0,
      infoTemplate: void 0,
      polygons: [],
      wait: 200,
      polygonOptions: {
        mouseover: {
          strokeColor: "#000",
          strokeOpacity: .5,
          strokeWeight: 1,
          fillColor: "#000",
          fillOpacity: .2
        },
        mouseout: {
          strokeWeight: 0,
          fillOpacity: 0
        }
      },
      infoWindowData: {
        state: void 0,
        hood: void 0,
        population: void 0,
        growth: void 0,
        density: void 0,
        males: void 0,
        females: void 0,
        median_income: void 0,
        average_income: void 0
      }
    });
    this.hoodQuery = function(data) {
      var query;
      query = ["SELECT geometry, HOOD_NAME, STATENAME, MARKET, LATITUDE, LONGITUDE"];
      query.push("FROM " + this.attr.tableId);
      query.push("WHERE LATITUDE >= " + data.lat1 + " AND LATITUDE <= " + data.lat2);
      query.push("AND LONGITUDE >= " + data.lng1 + " AND LONGITUDE <= " + data.lng2);
      return query.join(' ');
    };
    this.addHoodsLayer = function(ev, data) {
      var ToolTip;
      this.attr.gMap = data.gMap;
      this.attr.data = data;
      this.attr.currentHood = this.attr.data.hoodDisplayName || this.attr.data.hood || '';
      ToolTip = toolTip["class"]();
      if (!this.toolTip) {
        this.toolTip = new ToolTip(this.attr.gMap);
      }
      return this.getKmlData(data);
    };
    this.getKmlData = function(data) {
      var query, url;
      query = this.hoodQuery(data);
      url = [this.attr.fusionApiUrl];
      url.push(encodeURIComponent(this.hoodQuery(data)));
      url.push("&key=" + this.attr.apiKey);
      return $.ajax({
        url: url.join(""),
        dataType: "jsonp",
        success: (function(_this) {
          return function(data) {
            return _this.buildPolygons(data);
          };
        })(this)
      });
    };
    this.buildPolygons = function(data) {
      var hoodData, i, len, polygonData, results, row, rows;
      if (!(data && data.rows)) {
        return;
      }
      rows = data.rows;
      this.clearPolygons();
      results = [];
      for (i = 0, len = rows.length; i < len; i++) {
        row = rows[i];
        if (!rows[0]) {
          continue;
        }
        polygonData = this.buildPaths(row);
        hoodData = this.buildHoodData(row);
        results.push(this.wireupPolygon(polygonData, hoodData));
      }
      return results;
    };
    this.wireupPolygon = function(polygonData, hoodData) {
      var hoodLayer, initialOptions, isCurrentHood, mouseOutOptions, mouseOverOptions;
      mouseOverOptions = this.attr.polygonOptions.mouseover;
      mouseOutOptions = this.attr.polygonOptions.mouseout;
      isCurrentHood = this.attr.currentHood === hoodData.hood;
      initialOptions = isCurrentHood ? mouseOverOptions : mouseOutOptions;
      hoodLayer = new google.maps.Polygon(_.extend({
        paths: polygonData
      }, initialOptions));
      hoodLayer.setMap(this.attr.gMap);
      google.maps.event.addListener(hoodLayer, "mouseover", (function(_this) {
        return function(event) {
          hoodLayer.setOptions(mouseOverOptions);
          return _this.setupMouseOver(event, {
            data: hoodData,
            hoodLayer: hoodLayer
          });
        };
      })(this));
      google.maps.event.addListener(hoodLayer, "click", (function(_this) {
        return function(event) {
          var data;
          data = _.extend(hoodLayer, hoodData, event);
          return _this.showInfoWindow(event, hoodData);
        };
      })(this));
      google.maps.event.addListener(hoodLayer, "mouseout", (function(_this) {
        return function() {
          _this.toolTip.hide();
          if (!isCurrentHood) {
            return hoodLayer.setOptions(mouseOutOptions);
          }
        };
      })(this));
      this.attr.polygons.push(hoodLayer);
    };
    this.setupMouseOver = function(event, data) {
      if (!this.isMobile() && this.attr.enableMouseover) {
        return this.buildInfoWindow(event, data);
      }
    };
    this.showInfoWindow = function(event, polygonData) {
      return $.when(this.buildOnboardData(polygonData)).then((function(_this) {
        return function(infoData) {
          var html;
          if (infoData) {
            html = _.template(_this.attr.infoTemplate, infoData);
            return _this.toolTip.setContent(html);
          }
        };
      })(this));
    };
    this.buildInfoWindow = function(event, polygonData) {
      var html;
      if (!polygonData.data) {
        return polygonData.data;
      }
      html = _.template(this.attr.baseInfoHtml, polygonData.data);
      polygonData.hoodLayer.setMap(this.attr.gMap);
      this.toolTip.setContent(html);
      return this.toolTip.updatePosition(polygonData.hoodLayer);
    };
    this.buildPaths = function(row) {
      var coordinates, geometry;
      coordinates = [];
      if (geometry = row[0].geometry) {
        if (geometry.type === 'Polygon') {
          coordinates = this.makePathsCoordinates(geometry.coordinates[0]);
        }
      }
      return coordinates;
    };
    this.isValidPoint = function(arr) {
      return arr.length >= 2 && _.all(arr, _.isNumber);
    };
    this.makePathsCoordinates = function(coordinates) {
      if (this.isValidPoint(coordinates)) {
        return new google.maps.LatLng(coordinates[1], coordinates[0]);
      } else {
        return _.map(coordinates, this.makePathsCoordinates, this);
      }
    };
    this.buildHoodData = function(row) {
      if (typeof row[0] === 'object') {
        return _.object(['hood', 'state', 'city', 'lat', 'lng'], row.slice(1));
      } else {
        return {};
      }
    };
    this.buildOnboardData = function(polygonData) {
      if (!this.attr.enableOnboardCalls) {
        return polygonData;
      }
      return $.when(this.getOnboardData(polygonData)).then((function(_this) {
        return function(onboardData) {
          var data, demographic, key, ref, value;
          data = _.extend(_this.attr.infoWindowData, polygonData);
          if (!_.isEmpty(onboardData)) {
            demographic = onboardData.demographic;
            ref = _this.attr.infoWindowData;
            for (key in ref) {
              value = ref[key];
              if (demographic[key]) {
                data[key] = _this.formatValue(key, demographic[key]);
              }
            }
          }
          return data;
        };
      })(this));
    };
    this.clearPolygons = function() {
      var i, len, ref, x;
      if (!this.attr.polygons.length) {
        return;
      }
      ref = this.attr.polygons;
      for (i = 0, len = ref.length; i < len; i++) {
        x = ref[i];
        x.setMap(null);
      }
      this.attr.polygons = [];
    };
    this.formatValue = function(key, value) {
      switch (key) {
        case 'median_income':
        case 'average_income':
          return "$" + (parseInt(value, 10).toLocaleString()) + ".00";
        case 'population':
          return parseInt(value, 10).toLocaleString();
        default:
          return value;
      }
    };
    this.getOnboardData = function(data) {
      var query, xhr;
      if (_.isEmpty(data)) {
        return {};
      }
      query = [];
      query.push("state=" + (this.toDashes(data.state)));
      query.push("city=" + (this.toDashes(data.city)));
      query.push("neighborhood=" + (this.toDashes(data.hood)));
      return xhr = $.ajax({
        url: "/meta/community?rectype=NH&" + (query.join('&'))
      }).done(function(data) {
        return data;
      }).fail(function(data) {
        return {};
      }).always(function(data) {
        return data || {};
      });
    };
    this.toDashes = function(value) {
      if (value == null) {
        return '';
      }
      return value.replace(' ', '-');
    };
    this.toSpaces = function(value) {
      if (value == null) {
        return '';
      }
      return value.replace('-', ' ');
    };
    return this.after('initialize', function() {
      if (this.isMobile()) {
        return;
      }
      this.on(document, 'uiNeighborhoodDataRequest', this.addHoodsLayer);
      this.on(document, 'hoodMouseOver', this.setupMouseOver);
      this.on(document, 'hoodOnClick', this.showInfoWindow);
    });
  };
  return defineComponent(neighborhoodsOverlay, mobileDetection);
});
