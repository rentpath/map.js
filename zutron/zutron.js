define(['jquery', 'jquery-cookie'], function($, cookie) {

  var my = {
    zid: $.cookie('zid'),
    savedListings:{}
  };

  var getNewZid = function(error) {
    my.newZid = $.ajax({
      type:'get',
      dataType:'json',
      url:zutron_host + '/zids/new.json?t=' + new Date().getTime(),
      error:error
    });
    my.newZid.done(function(data) {
      my.zid = data['zid']['key'];
      if (my.zid) {
        $.cookie('zid', my.zid, {
          expires: 90,
          domain: location.host,
          path: '/'});
        $('body').trigger('new_zid_obtained');
      } else {
        error();
      }
    });
    my.newZid.fail(error);
  };

  var init = function(error) {
    // TODO - move error message functionality out of init
    $('a.icon_favorites').unbind('click').on('click', function(){
      displayErrorMessage();
    });
    if (my.zid) {
      // verify zid is still valid
      getDataForZid(
        function() {
          //console.log('zid is OK!');
        },
        function() {
          //console.log('stale zid found: ' + my.zid);
          delete my.zid;
          $.cookie('zid', null);
          getNewZid(error);
        });
    } else if (!my.newZid) {
      getNewZid(error);
    }
  };

  var getZid = function(error, cb) {
    if (my.newZid) {         // retrieving zid so promise to call me
      my.newZid.done(cb);
      my.newZid.fail(error);
    } else if (my.zid) {     // zid in hand
      cb();
    } else {                 // whoops
      error();
    }
  };

  var getDataForZid = function (success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      $.ajax({
        type:'get',
        dataType:'json',
        url:zutron_host + '/zids/' + my.zid + '.json?t=' + new Date().getTime(),
        success:success,
        error:error
      });
    });
  };

  var displayErrorMessage = function(errorText){
    var errorDiv = $('#zutron_error');
    errorDiv.prm_dialog_open();
    errorDiv.on('click', 'a.close',function(){
      errorDiv.prm_dialog_close();
    });
    if (errorText){
      $('#snapbar_error').text(errorText);
    }
  };

  var tackOnTimestamp = function(url) {
    return (url.indexOf('?') < 0 ? '?' : '&') + 't=' + new Date().getTime();
  };

  var toggleListingState = function(saved, listing_id, success, error) {
    getZid(function(){
        displayErrorMessage();
        error();
      }, function() {
      if (!my.zid) return false;

      // Kludging Rails :edit to be :delete', so to delete we do an HTTP GET with a /edit
      var operation  = saved ? 'get' : 'post';

      var url = zutron_host;
      if (saved) {
        url += '/zids/' + my.zid + '/listings/' + listing_id + '/edit';
      } else {
        url += '/zids/' + my.zid + '/listings'

        var params = {
          listing: {
            id: listing_id
          },
          source: location.host
        };
        url += '?' + jQuery.param(params);
      };

      url += tackOnTimestamp(url);

      $.ajax({
        type: operation,
        url:  url,
        success: success,
        error: error
      });
    });
  };

  var toggleSearchState = function(saved, search_id, city, state, zip, hood, refinements, search, name, success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      var operation  = saved ? 'get' : 'post';
      var url        = zutron_host + '/zids/' + my.zid + '/searches/';
      if (!saved) {
        var params = {
          search:{
            source: location.host,
            id:search_id,
            city:city,
            state:state,
            zip:zip,
            hood:hood,
            refinements:refinements,
            name:name,
            query:search
          }
        };
        url += '?' + jQuery.param(params);
      } else {
        url += search_id + '/edit';
      }

      $.ajax({
        type:operation,
        url:url,
        success:success,
        error:error
      });
    });
  };

  var saveSearch = function(search_id, city, state, zip, hood, refinements, search, name, success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      var url = zutron_host + '/zids/' + my.zid + '/searches/';
      var params = {
        search:{
          source: location.host,
          id:search_id,
          city:city,
          state:state,
          zip:zip,
          hood:hood,
          refinements:refinements,
          name:name,
          query:search
        }
      };
      url += '?' + jQuery.param(params);

      $.ajax({
        type:'post',
        url:url,
        success:success,
        error:error
      });
    });
  };

  var renameSavedSearch = function(search_id, new_name, success, error) {
    getZid(error, function() {
      if (!my.zid)return false;

      var url = zutron_host + '/zids/' + my.zid + '/searches/' + search_id + '/revise.json';
      var params = {
        search:{
          name:new_name
        }
      };
      url += '?' + jQuery.param(params);

      $.ajax({
        type:'get',
        url:url,
        success:success,
        error:error
      });
    });
  };

  var deleteSavedProperty = function(listing_id, success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      var url = zutron_host + "/zids/" + my.zid + '/listings/' + listing_id + '/edit.json';
      url += tackOnTimestamp(url);

      $.ajax({
        type: 'get',
        url: url,
        success: success,
        error: error
      });
    });
  };

  var deleteSavedSearch = function(search_id, success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      var url = zutron_host + '/zids/' + my.zid + '/searches/' + search_id + '/edit';
      url += tackOnTimestamp(url);

      $.ajax({
        type: 'get',
        url: url,
        success: success,
        error: error
      });
    });
  };

  var addComparedProperty = function(listing_id, success, error) {
    getZid(error, function() {
      if (!my.zid) return false;

      var url = zutron_host + '/zids/' + my.zid + '/comparisons.json';
      var params = {
        comparison: {
          listing_id: listing_id
        }
      };

      url += '?' + jQuery.param(params);
      url += tackOnTimestamp(url);

      $.ajax({
        type: 'POST',
        cache: false,
        url: url,
        success: success,
        error: error
      });
    });
  };

  var removeComparedProperty = function(comparison_id, success, error) {
    getZid(error, function(){
      if (!my.zid) return false;

      var url = zutron_host + '/zids/' + my.zid + '/comparisons/' + comparison_id + '/edit.json';
      url += tackOnTimestamp(url);

      $.ajax({
        type: 'GET',
        cache: false,
        url: url,
        success: success,
        error: error
      });
    });
  };

  var getComparedProperties = function(success, error) {
    getZid(error, function(){
      if (!my.zid) return false;

      var url = zutron_host + '/zids/' + my.zid + '/comparisons.json';
      url += tackOnTimestamp(url);

      $.ajax ({
        type: 'GET',
        dataType:'json',
        url: url,
        success: success,
        error: error
      });
    });
  };

  var getSavedListings = function() {
      getDataForZid(function(data) {
        for (var i = 0; i < data['zid']['listings'].length; i++) {
          var listing_id = data['zid']['listings'][i]['listing']['listing_id'];
          my.savedListings[listing_id] = 1;
          var icon = $('a.icon_favorites[data-listingid=' + listing_id + '] span.icon_favorites');
          $(icon).addClass('icon_favorites_on');
      }
      bindSaveListings();
    });
  };

  var bindSaveListings = function() {
    $('a.icon_favorites').unbind('click').click(function(event) {
      event.preventDefault();
      var listing_id = $(this).attr('data-listingid');
      var saved = my.savedListings[listing_id];
      my.spanClicked = event.target;
      toggleListingState(saved, listing_id, function(data) {
        if (!saved) {
          my.savedListings[listing_id] = 1;
        } else {
          delete my.savedListings[listing_id];
        }
        $(my.spanClicked).toggleClass('icon_favorites_on');
      });
      return false;
    });
  };

  var findById = function (source, id){
    return _.filter(source, function(obj){
      return obj.listing_id == id;
    })[0];
  };

  return {
    init: init,
    getDataForZid:getDataForZid,
    saveSearch: saveSearch,
    toggleListingState: toggleListingState,
    toggleSearchState: toggleSearchState,
    deleteSavedProperty: deleteSavedProperty,
    deleteSavedSearch: deleteSavedSearch,
    addComparedProperty: addComparedProperty,
    getComparedProperties: getComparedProperties,
    removeComparedProperty: removeComparedProperty,
    getSavedListings: getSavedListings,
    tackOnTimestamp: tackOnTimestamp,
    findById: findById,
    renameSavedSearch: renameSavedSearch,
    displayErrorMessage: displayErrorMessage
  };
});

