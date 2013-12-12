define(['jquery-cookie-rjs', 'primedia_events'], function(cookie, events) {

  var my = {
    zid: $.cookie('zid'),
    zidData: {},
    savedListings:{}
  };

  var init = function() {
    var $favorites = $('a.icon_favorites');
    bindErrorMessageToFavorites($favorites)
  };

  var bindErrorMessageToFavorites = function(favorites){
    if (!favorites.data('boundToSave')){
      favorites.unbind('click').on('click', function(){
        displayErrorMessage();
      });
    }
  };

  var createZid = function() {
    var defer = $.ajax({
      type:'get',
      dataType:'json',
      url:zutron_host + '/zids/new.json?t=' + new Date().getTime()
    });

    defer.done(function(data) {
      var zid = data.zid.key;
      my.zid = zid;
      $.cookie('zid', zid, {
        expires: 90,
        domain: location.host,
        path: '/'
      });
      $('body').trigger('new_zid_obtained');
    });

    defer.fail(function(jqXHR, textStatus, errorThrown) {
      // TODO: Improve error handling when Zutron is down.
      // Need to prevent popups on every page when Zutron is unavailable
      // displayErrorMessage();
    });

    return defer;
  };

  var ensureZid = function(ajaxCall) {
    var defer = $.Deferred();
    var success = function() { defer.resolve(); };
    var error = function() { defer.reject(); };
    var retryWithNewZid = function() {
      createZid().done(function() {
        ajaxCall().done(success).fail(error);
      });
    };

    if (!my.zid) {
      retryWithNewZid();
      return defer;
    }

    ajaxCall()
      .done(success)
      .fail(function(jqXHR, textStatus, errorThrown) {
        if (jqXHR.status == '410') {
          retryWithNewZid();
        } else {
          error();
        }
      });

    return defer;
  };

  var getDataForZid = function() {
    // return defer if in process
    if (my.getDataForZidInPress) {
      return my.getDataForZipDefer;
    }
    my.getDataForZipDefer = $.Deferred();
    my.getDataForZidInPress = true;

    var url = function() {
      return zutron_host + '/zids/' + my.zid + '.json?t=' + new Date().getTime();
    };
    var success = function(data) {
      my.zidData = data;
      my.getDataForZipDefer.resolve(data);
    };
    var error = function() {
      my.getDataForZipDefer.reject();
    };
    var complete = function() {
      my.getDataForZidInPress = false;
    };
    var ajaxCall = function() {
      return $.ajax({
        type:'get',
        dataType:'json',
        url:url()
      }).done(success)
        .fail(error)
        .always(complete);
    };

    ensureZid(ajaxCall);

    return my.getDataForZipDefer;
  };

  var displayErrorMessage = function(errorText){
    var errorDiv = $('#zutron_error');
    errorDiv.prm_dialog_open();
    errorDiv.on('click', 'a.close',function(){
      errorDiv.prm_dialog_close();
    });
    if (errorText){
      $('#zutron_error .padding_box p').text(errorText);
    }
  };

  var tackOnTimestamp = function(url) {
    return (url.indexOf('?') < 0 ? '?' : '&') + 't=' + new Date().getTime();
  };

  var toggleListingState = function(saved, listing_id, success, error) {
    // Kludging Rails :edit to be :delete', so to delete we do an HTTP GET with a /edit
    var operation  = saved ? 'get' : 'post';

    var requestUrl = function() {
      var url = zutron_host;
      if (saved) {
        url += '/zids/' + my.zid + '/listings/' + listing_id + '/edit';
      } else {
        url += '/zids/' + my.zid + '/listings';
        var params = {
          listing: {
            id: listing_id
          },
          source: location.host
        };
        url += '?' + jQuery.param(params);
      }
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type: operation,
        url: requestUrl()
      }).done(success)
        .fail(function() {
          displayErrorMessage();
          error();
        });
    };

    return ensureZid(ajaxCall);
  };

  var toggleSearchState = function(saved,search_id, city, state, zip, hood,
                                   refinements, search, name, success, error) {

    var operation  = saved ? 'get' : 'post';
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/searches/';
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
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:operation,
        url: requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var _savedSearchSource = function(host) {
    var mdot_regex = /(^m\.(ci\.|qa\.|apartmentguide\.)|^local\.m\.)/;
    if (host.match(mdot_regex) !== null) {
      return 'mdot';
    } else {
      return 'ag';
    }
  };

  var saveSearch = function(search_id, city, state, zip, hood,
                            refinements, search, name, success, error) {

    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/searches/';
      var params = {
        search:{
          source: _savedSearchSource(location.host),
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
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:'post',
        url:requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var renameSavedSearch = function(search_id, new_name, success, error) {
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/searches/' + search_id + '/revise.json';
      var params = {
        search:{
          name:new_name
        }
      };
      url += '?' + jQuery.param(params);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:'get',
        url:requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var deleteSavedProperty = function(listing_id, success, error) {
    var requestUrl = function() {
      var url = zutron_host + "/zids/" + my.zid + '/listings/' + listing_id + '/edit.json';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:'get',
        url:requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var deleteSavedSearch = function(search_id, success, error) {
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/searches/' + search_id + '/edit';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:'get',
        url:requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var addComparedProperty = function(listing_id, success, error) {
    var url = zutron_host + '/zids/' + my.zid + '/comparisons.json';
    var params = {
      comparison: { listing_id: listing_id }
    };
    var data = {
      url: urlWithParams(url,params),
      requestType: 'POST'
    };

    sendUserData(data, success, error);
  };

  var saveFilters = function(filters, success, error) {
    var url = zutron_host + '/zids/' + my.zid + '/profile/edit.json';
    var params = { profile: {filters: filters} };
    var data = {
      url: urlWithParams(url, params),
      requestType: 'GET'
    };
    sendUserData(data, success, error);
  };

  var getProfileData = function(success, error){
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/profile.json';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax ({
        type: 'GET',
        dataType:'json',
        url: requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var urlWithParams = function(url, params){
    url += '?' + jQuery.param(params);
    url += tackOnTimestamp(url);
    return url;
  };

  var sendUserData = function(dataJson, success, error){
    var requestType = dataJson.requestType || 'POST';

    var ajaxCall = function() {
      return $.ajax({
        type: requestType,
        cache: false,
        dataType:'json',
        url: dataJson.url
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var removeComparedProperty = function(comparison_id, success, error) {
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/comparisons/' + comparison_id + '/edit.json';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type: 'GET',
        cache: false,
        url: requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var getComparedProperties = function(success, error) {
    var requestUrl = function() {
      var url = zutron_host + '/zids/' + my.zid + '/comparisons.json';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax ({
        type: 'GET',
        dataType:'json',
        url: requestUrl()
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  var bindSaveListings = function() {
    $('a.icon_favorites').data('boundToSave', true).unbind('click').click(function(event) {
      event.preventDefault();
      var listing_id = $(this).attr('data-listingid');
      var saved = my.savedListings[listing_id];
      my.spanClicked = event.target;
      toggleListingState(saved, listing_id, function(data) {
        var icon = $('a.icon_favorites[data-listingid=' + listing_id + '] span.icon_favorites');
        if (!saved) {
          my.savedListings[listing_id] = 1;
          $(icon).addClass('icon_favorites_on');
          events.trigger('zutron/save_listing', listing_id)
        } else {
          delete my.savedListings[listing_id];
          $(icon).removeClass('icon_favorites_on');
          events.trigger('zutron/delete_listing', listing_id)
        }
      });
      return false;
    });
  };

  var getSavedListings = function() {
    getDataForZid().done(function() {
      var data = my.zidData;
      for (var i = 0; i < data['zid']['listings'].length; i++) {
        var listing_id = data['zid']['listings'][i]['listing']['listing_id'];
        my.savedListings[listing_id] = 1;
        var icon = $('a.icon_favorites[data-listingid=' + listing_id + '] span.icon_favorites');
        $(icon).addClass('icon_favorites_on');
      }
      bindSaveListings();
      events.trigger("zutron/savedListings", data);
    });
  };


  var getListingData = function(listing_id, success, error) {
    var requestUrl = function() {
      var url = zutron_host + "/zids/" + my.zid + '/listings/' + listing_id + '/exists.json';
      url += tackOnTimestamp(url);
      return url;
    };

    var ajaxCall = function() {
      return $.ajax({
        type:'get',
        url:requestUrl(),
        dataType: 'json'
      }).done(success)
        .fail(error);
    };

    return ensureZid(ajaxCall);
  };

  // FIXME: Why put this method here?  ~Daniel
  var findById = function (source, id, key){
    return _.filter(source, function(obj){
      if (key) {
        return eval("obj."+key).listing_id == id;
      }  else {
        return obj.listing_id == id;
      }
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
    bindSaveListings: bindSaveListings,
    tackOnTimestamp: tackOnTimestamp,
    findById: findById,
    renameSavedSearch: renameSavedSearch,
    displayErrorMessage: displayErrorMessage,
    saveFilters: saveFilters,
    getProfileData: getProfileData,
    getListingData: getListingData
  };
});
