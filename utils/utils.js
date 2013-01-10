define(['jquery', 'underscore'], function ($, _) {
  var imageServerCount = 2;
  var nextImageServer = 0;

  var longStateName = function(state) {
    var table = {
      "AL":"Alabama",
      "AK":"Alaska",
      "AZ":"Arizona",
      "AR":"Arkansas",
      "CA":"California",
      "CO":"Colorado",
      "CT":"Connecticut",
      "DE":"Delaware",
      "DC":"District of Columbia",
      "FL":"Florida",
      "GA":"Georgia",
      "HI":"Hawaii",
      "ID":"Idaho",
      "IL":"Illinois",
      "IN":"Indiana",
      "IA":"Iowa",
      "KS":"Kansas",
      "KY":"Kentucky",
      "LA":"Louisiana",
      "ME":"Maine",
      "MD":"Maryland",
      "MA":"Massachusetts",
      "MI":"Michigan",
      "MN":"Minnesota",
      "MS":"Mississippi",
      "MO":"Missouri",
      "MT":"Montana",
      "NE":"Nebraska",
      "NV":"Nevada",
      "NH":"New Hampshire",
      "NJ":"New Jersey",
      "NM":"New Mexico",
      "NY":"New York",
      "NC":"North Carolina",
      "ND":"North Dakota",
      "OH":"Ohio",
      "OK":"Oklahoma",
      "OR":"Oregon",
      "PA":"Pennsylvania",
      "RI":"Rhode Island",
      "SC":"South Carolina",
      "SD":"South Dakota",
      "TN":"Tennessee",
      "TX":"Texas",
      "UT":"Utah",
      "VT":"Vermont",
      "VA":"Virginia",
      "WA":"Washington",
      "WV":"West Virginia",
      "WI":"Wisconsin",
      "WY":"Wyoming",
      "AS":"American Samoa",
      "GU":"Guam",
      "MP":"Northern Mariana Islands",
      "PR":"Puerto Rico",
      "VI":"Virgin Islands",
      "FM":"Federated States of Micronesia",
      "MH":"Marshall Islands",
      "PW":"Palau",
      "CZ":"Canal Zone",
      "PI":"Philippine Islands",
      "TT":"Trust Territory of the Pacific Islands",
      "CM":"Commonwealth of the Northern Mariana Islands"
    };
    return table[state] || state;
  };

  var baseUrl = function() {
    return 'http://' + location.hostname;
  };

  var searchUrl = function() {
    var url = baseUrl();

    var searchMatch = location.pathname.match(/(\/apartments\/[^\/]+\/[^\/]+\/)|(\/zip\/[^\/]+\/)|(\/neighborhoods\/[^\/]+\/[^\/]+\/[^\/]+\/)/);
    if (searchMatch && (searchMatch.length > 0)) {
      url += searchMatch[0];
    }

    return url;
  };

  var imageUrl = function(photoList, w, h) {

    var path;

    if ($.isArray(photoList)) {
      if (photoList.length === 0) {
        return imageNotFoundURL();
      }
      path = _.first(photoList).path;
    } else {
      path = photoList;
    }

    if (path[0] != '/') {
      path = '/' + path;
    }

    var url = "http://image";

    if (nextImageServer > 0) {
      url += nextImageServer;
    }
    nextImageServer += 1;
    if (nextImageServer >= imageServerCount) {
      nextImageServer = 0;
    }

    url += ".apartmentguide.com";
    url += path;

    if (w || h) {
      if (w) {
        url += w;
      }
      url += "-";
      if (h) {
        url += h;
      }
    }

    return url;
  };

  var assetURL = function() {
    return $('meta[name="asset_host"]').attr('content');
  };

  var imageNotFoundURL = function() {
    return assetURL() + "/images/prop_no_photo_results.png";
  };

  var getListings = function(selector) {
    var listingSelector = selector ? selector : '#listingData';
    var listingData = $(listingSelector).data('listingdata');

    if (listingData) {
      listingData.total_pages = listingData.total_pages || 0;
    }
    return listingData;
  };

  var parseDomainPath = function(value) {
    var matchedString = value.match(/(^.*?)(?=#?\??filters)/);
    return matchedString ? matchedString[1] : "";
  };
  var parsePageIndex = function(value) {
    var match = value.match(new RegExp("[?&]page(?:=([^&]*))?", "i"));
    return (match && match[1] ? Number(match[1]) : 1);
  };

  var storeSemFlag = function() {
    var regex = new RegExp("[?&]wt.mc_id(?:=([^&]*))?", "i"),
      match = window.location.search.match(regex);
    if (match && match[1]) {
      localStorage.removeItem('campaign_id');
      localStorage.setItem('campaign_id', match[1]);
    }
  };

  var showSemOrSeoNumber = function() {
    if (localStorage.getItem("campaign_id") || localStorage.getItem("blthmpg")) {
      $('.sem_number').show();
      $('.non_sem_number').hide();
      return true;
    } else {
      $('.non_sem_number').show();
      $('.sem_number').hide();
      return false;
    }
  };

  var getPageInfo = function() {
    var pageInfo = {};
    $.each($('meta.pageInfo'), function(index, tag) {
      pageInfo[tag.name] = tag.content;
    });

    pageInfo.nodes = pageInfo.nodes ? pageInfo.nodes.split(",") : [];
    return pageInfo;
  };

  var wireupSocialDialogs = function(){
    var navLinks = $('ul#nav');
    toggleLogIn();

    navLinks.on('click', 'li a.login', function(){
      var self = $('#zutron_login_form');
      self.prm_dialog_open();
      wireupSocialLinks(self);
    });

    navLinks.on('click', 'li a.logout', function(){
      toggleLogIn();
      logOut();
    });

    navLinks.on('click', 'li a.register', function(){
      var self = $('#zutron_register_form');
      self.prm_dialog_open();
      wireupSocialLinks(self);
    });
  };

  var wireupSocialLinks = function(div){
    var zid = $.cookie('zid') || '';
    var baseUrl = zutron_host + '?zid_id=' + zid;
    var fbLink = div.find('a.icon_facebook48');
    var twitterLink = div.find('a.icon_twitter48');
    var googleLink = div.find('a.icon_google_plus48');

    redirectTo(fbLink, baseUrl + '&technique=facebook');
    redirectTo(twitterLink, baseUrl + '&technique=twitter');
    redirectTo(googleLink, baseUrl + '&technique=googleplus');

    div.on('click', 'a.icon_close', function(){
      div.prm_dialog_close();
    });
    div.on('click', 'a.cancel', function(){
      div.prm_dialog_close();
    });
  };

  // redirectTo will prevent a second authentication if user hits the back button after logging in
  var redirectTo = function(link,url){
    $(link).on('click', function(){
      var staySignedIn = $('.zutron_login_popup :checkbox')[0].checked || $('.zutron_register_popup :checkbox')[0].checked;
      if (staySignedIn){
        $.cookie('sgn','stay');
      } else{
        expireCookie('sgn');
      }
      window.location.replace(url);
    });
  };

  var toggleLogIn = function(){
    if (($.cookie('sgn') == 'temp') || (($.cookie('sgn') == 'perm'))){
      $('ul#nav li a.login').attr('class','logout').text('Logout');
    } else{
      $('ul#nav li a.login').attr('class','login').text('Login');
    }
  };

  var logOut = function(){
    var returnUrl = window.location.href;

    expireCookie('zid');
    expireCookie('sgn');
    window.location.replace(returnUrl);
  };

  var expireCookie = function(cookie){
    var expire = new Date(1);
    var domain = '.' + window.location.host;
    var options = {'expires':expire, 'path':'/', 'domain':domain};

    $.cookie(cookie,'', options);
  };

  var removeTelco = function(telco) {
    var telcos = {
      'has_verizon':'verizon-desc',
      'has_attuverse':'attuverse-desc',
      'has_brighthouse':'brighthouse-desc',
      'has_charter':'charter-desc',
      'has_xfinity':'xfinity-desc',
      'has_timewarner':'timewarner-desc'
    };
    $('.sort_controls option[value="' + telcos[telco] + '"]').remove();
  };

  var removeCategories = function(features) {
    var checkOffList = {
      '4lc':'iscorporate-desc',
      '4lf':'issenior-desc',
      '4lg':'isincome-desc',
      '4lh':'ispet-desc',
      '4li':'isluxury-desc'
    };
    $.each(features, function(ind, feature) {
      if (checkOffList[feature.id] != 'undefined') {
        delete checkOffList[feature.id];
      }
    });
    $.each(checkOffList, function(key, value) {
      $('.sort_controls option[value="' + value + '"]').remove();
    });
  };

  var wireupTelcoSortBar = function(listings) {
    var telco_markets = listings.telco_markets;

    if (typeof telco_markets === 'undefined') {
      return;
    }

    // var telco_markets = listings.telco_markets;
    var sortString = '';
    if (telco_markets.has_verizon) {
      sortString = 'This sort has produced the following Verizon FiOS enabled properties';
      $('#vzn_sort_bar').show();
      $('#find_mover').hide();
      $('#find_verizon_tab').show();
      if (sortValue() == 'verizon-desc') {
        $('.sort_controls select').val('verizon-desc');
        $('#vzn_sort_bar a').html(sortString);
      }
      $('#vzn_sort_bar a').click(function() {
        $('.sort_controls select').val('verizon-desc').trigger('change');
        $(this).html(sortString);

      });
      $('#find_verizon_tab').click(function() {
        $('.sort_controls select').val('verizon-desc').trigger('change');
      });
    } else if (telco_markets.has_attuverse) {
      sortString = 'This sort has produced the following AT&T U-Verse enabled properties';
      $('#att_sort_bar').show();
      if (sortValue() == 'attuverse-desc') {
        $('.sort_controls select').val('attuverse-desc');
        $('#att_sort_bar a').html(sortString);
      }
      $('#att_sort_bar a').click(function() {
        $('.sort_controls select').val('attuverse-desc').trigger('change');
        $(this).html(sortString);
      });
    }

    if (!telco_markets.has_brighthouse) {
      $('.sort_controls select option[value="brighthouse-desc"]').remove();
    }
  };

  var telcoText = function() {
    var selection = $('.sort_controls option:selected').val();
    if (selection != 'verizon-desc' || selection != 'attuverse-desc' || selection != 'timewarner-desc') {
      $('#att_sort_bar a').html('Sort By AT&T U-Verse');
      $('#vzn_sort_bar a').html('Sort By Verizon FiOS');
    }
  };

  var sortValue = function() {
    var params = window.location.search.substr(1).split('&');
    for (var i = 0; i < params.length; i++) {
      var match = params[i].match(/sort=(.+)/);
      if (match) {
        return match[1];
      }
    }

    return '';
  };

  var sortUrl = function(sortSelection) {
    var url = 'http://' + window.location.host + window.location.pathname + '?';
    var params = window.location.search.substr(1).split('&');
    for (var i = 0; i < params.length; i++) {
      if (!params[i].match(/^page/) && !params[i].match(/^sort/)) {
        url += params[i] + '&';
      }
    }
    if (sortSelection != 'default') {
      url += 'sort=' + sortSelection + '&';
    }
    url += 'page=1';

    return url;
  };

  var wireupSortBars = function(page) {

    removeCategories(page.listings.filters.community_features);
    var telco_markets = page.listings.telco_markets;
    $.each(telco_markets, function(key, value) {
      if (!value) {
        removeTelco(key);
      }
    });
    $('.sort_links a').click(function() {
      $('.sort_controls select').val($(this).data('sort')).trigger('change');
    });
    var sortControls = page.listingControls + ' .sort_controls:visible';

    $(sortControls).change(function() {

      if ((page.pageInfo.type == 'search') || (page.pageInfo.type == 'search_b')) {
        var selection = $(sortControls + ' option:selected').val();

        window.location = sortUrl(selection);
      } else {
        if ($('#vzn_sort_bar').is(':visible') || $('#att_sort_bar').is(':visible')) {
          telcoText();
        }
        page.onIndexUpdated(1);
        $(page.listingsSelector).paginate({
          target:page.paginateSelector,
          totalPages:page.totalPages,
          indexUpdated:page.onIndexUpdated
        });
      }
    });
  };

  var setVerizonTab = function(pageInfo) {
    var state = pageInfo.state.toLowerCase(),
      url,
      states = ['california', 'delaware', 'district-of-columbia', 'florida', 'maryland', 'virginia', 'new-jersey', 'new-york', 'pennsylvania', 'rhode-island', 'texas', 'massachusetts'];
    url = 'http://' + location.host + '/' + pageInfo.channel + '/' + pageInfo.state + '/' + pageInfo.city;

    if ($.inArray(state, states) != -1) {
      $('#find_mover').hide();
      $('#find_verizon_tab').show();
    }

  };

  var setVerizonHomePageLink = function(city, state, channel) {
    var host = location.host,
      url;
    url = 'http://ad.doubleclick.net/clk;252281777;63013666;l?' + 'http://' + host + '/' + channel + '/' + state + '/' + city + '?sort=verizon-desc';
    $('#find_verizon_tab').attr('href', url);
  };

  var setVerizonLink = function(info, url) {
    if (!url) {
      url = 'http://' + location.host + '/' + info.channel + '/' + info.state + '/' + info.city;
    }
    var verizon_tab = $('#find_verizon_tab'),
      pageType = info.type,
      qt = url.match(/\?/) ? '&' : '?',
      vzSort = url.match(/verizon/),
      searchLink = 'http://ad.doubleclick.net/clk;252281778;63013666;m?',
      detailLink = 'http://ad.doubleclick.net/clk;252281779;63013666;n?',
      thankYouLink = 'http://ad.doubleclick.net/clk;252281780;63013666;f?',
      kaLink;

    if (verizon_tab) {
      switch (pageType) {
        case 'search':
          kaLink = searchLink;
          break;
        case 'detail':
          kaLink = detailLink;
          break;
        case 'thankyou':
          kaLink = thankYouLink;
          break;

      }
      if (vzSort) {
        return verizon_tab.attr('href', kaLink + url);
      }
      else {
        return verizon_tab.attr('href', kaLink + url + qt + "sort=verizon-desc");
      }

    }
  };


  var setStorageItem = function(key, value) {
    if (!key || !value) {
      return false;
    }
    try {
      window.localStorage.removeItem(key);
      window.localStorage.setItem(key, value);
      return true;
    } catch (error) {
      if (error.code === DOMException.QUOTA_EXCEEDED_ERR && window.localStorage.length === 0) {
        return false;
      }
    }
  };

  var removeStorageItem = function(key) {
    return window.localStorage.removeItem(key);
  };

  (function() {
    $('body').on('click', 'a.new_window', function(e) {
      var url = $(this).attr("href");
      if (url) {
        window.open($(this).attr("href"), "_blank");
        WH.elemClicked(e, {followHref: false});
        return false;
      }
    });
  })();

  var exists = function(thing) {
    return thing !== undefined && thing !== null;
  };
  var showSpinner = function() {
    var height = $(window).height();
    var width = $(window).width();
    var x = (width / 2) - $('.spinner').width() / 2;
    var y = (height / 2) - $('.spinner').height() / 2;

    $('.spinner').show();
    $('.spinner').css({top:y, left:x});
  };

  var slideshowTracking = function() {
    var slideshowType = "";
    Galleria.ready(function() {
      if ($('.large#details_top').is(':visible')) {
        slideshowType = 'carousel';
        this.bind("thumbnail", function(e) {
          $(e.thumbTarget).addClass('carouselThumbPhoto');
        });
      } else {
        slideshowType = 'nonFree';
        this.bind("thumbnail", function(e) {
          $(e.thumbTarget).addClass('nonFreeThumbPhoto');
        });
      }

      $('.galleria-image-nav-right,.galleria-image-nav-left').click(function() {
        WH.fire({sg:'galleria-image', item:slideshowType + 'SlideShowPhoto', type:'click'});
      });
    });
  };

  var leadTracking = function(listingId) {
    $('body').bind('lead_submission', function(e) {

      WH.fire({
        listingid:listingId,
        type:'submission'
      });
    });
  };

  var parseQuery = function() {
    var queryAsAssoc = {};
    var queryString = top.location.search.substring(1);
    var keyValues = queryString.split(/&/);

    for (var i = 0; i < keyValues.length; i++) {
      var key = keyValues[i].split('=');
      queryAsAssoc[key[0]] = key[1];
    }

    return queryAsAssoc;
  };

  var toQueryString = function(queryHash) {
    return _.map(queryHash,function(val, key) {
      return key + '=' + val;
    }).join('&') || '';
  };

  var addRefinementToUrl = function(jqElem) {
    var url = jqElem.attr('href');
    var slug_array = window.location.pathname.split('/');
    var value = slug_array[slug_array.length-2];
    if (value.match(/\d[A-Za-z]+/)) {
      jqElem.attr('href', url + value + '/');
    }
  };

  var tabSwitcher = function() {
    var tab_content = $('.tabbed_content .tab_content');
    var li_first = $('.tabbed_content .global_tabs li:first, .tabbed_content .tabs li:first');
    var anchor_rel = $($('.tabbed_content .global_tabs li:first a, .tabbed_content .tabs li:first a').attr('rel'));
    var tab_li = $('.tabbed_content .global_tabs li, .tabbed_content .tabs li');

    tab_content.hide();
    li_first.addClass('active');
    anchor_rel.addClass('active_content').show();

    tab_li.click(function(){
      $(this).addClass('active');
      $(this).siblings().removeClass('active');
      $('.active_content', $(this).parents('.tabbed_content')).removeClass('active_content').hide();
      $($('a', $(this)).attr('rel')).addClass('active_content').show();
      return false;
    });

  };

  var showDfp = function() {
    var now = new Date(), cutover = new Date(2013, 1, 1);
        return now >= cutover;
    };

  var isSem = function() {
    return (localStorage.getItem("campaign_id") || localStorage.getItem("blthmpg")) ? true : false;
  };


  return  {
    exists:exists,
    setStorageItem:setStorageItem,
    removeStorageItem:removeStorageItem,
    imageNotFoundURL:imageNotFoundURL,
    assetURL:assetURL,
    getListings:getListings,
    parseDomainPath:parseDomainPath,
    parsePageIndex:parsePageIndex,
    baseUrl:baseUrl,
    searchUrl:searchUrl,
    imageUrl:imageUrl,
    longStateName:longStateName,
    storeSemFlag:storeSemFlag,
    showSemOrSeoNumber:showSemOrSeoNumber,
    getPageInfo:getPageInfo,
    wireupTelcoSortBar:wireupTelcoSortBar,
    setVerizonTab:setVerizonTab,
    setVerizonHomePageLink:setVerizonHomePageLink,
    setVerizonLink:setVerizonLink,
    wireupSortBars:wireupSortBars,
    showSpinner:showSpinner,
    sortValue:sortValue,
    slideshowTracking:slideshowTracking,
    leadTracking:leadTracking,
    parseQuery:parseQuery,
    toQueryString:toQueryString,
    wireupSocialDialogs:wireupSocialDialogs,
    addRefinementToUrl:addRefinementToUrl,
    showDfp:showDfp,
    isSem:isSem,
    tabSwitcher: tabSwitcher
  };
});
