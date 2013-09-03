describe("Autotagging Suite", function() {
  var wh, simulPlatform, testDocument, testWindow;

  beforeEach(function() {
    var ready = false;

    require(['../../jquery.autotagging'], function(WH) {
      wh = new WH();
      wh.platform = {OS: 'OS', browser: 'dummy', version: ''};
      testWindow = $('<div></div>');
      ready = true;
    });

    waitsFor(function(){
      return ready;
    });
  });

  describe("Instance Methods", function() {
    it('#determineWindowDimensions returns a string for window dimensions', function() {
      testWindow.width(100).height(100);
      expect(wh.determineWindowDimensions(testWindow)).toEqual('100x100');
    });

    it('#determineWindowDimensions returns a string for document dimensions', function() {
      testWindow.width(100).height(100);
      expect(wh.determineWindowDimensions(testWindow)).toEqual('100x100');
    });

    describe("#fire", function() {
      var callback;
      var obj = {};

      beforeEach(function() {
        callback = {
          fightFire: function(obj) {
            obj.blaze = true;
            return obj;
          }
        };

        wh.fireCallback = callback.fightFire;
        spyOn(wh, 'fireCallback').andCallThrough();
      });

      it('calls the given callback', function () {
        wh.fire(obj);
        expect(obj.blaze).toEqual(true);
        expect(wh.fireCallback).toHaveBeenCalled();
      });

      it('amends the object with the one time data ONCE', function() {
        wh.setOneTimeData({auxiliary: 'secret'});
        wh.fire(obj);
        expect(obj.auxiliary).toEqual('secret');

        next = {};
        wh.fire(next);
        expect(next.auxiliary).toEqual(undefined);
      });

      describe('records login information', function() {
        var signon_cookie;
        var provider_cookie;
        var zid_cookie;

        beforeEach(function() {
          provider_cookie = $.cookie('provider');
          signon_cookie   = $.cookie('sgn');
          zid_cookie      = $.cookie('zid');
        });

        afterEach(function() {
          $.cookie('provider', provider_cookie, {expires: 3650, path: '/'});
          $.cookie('sgn', signon_cookie, {expires: 3650, path: '/'});
          $.cookie('zid', zid_cookie, {expires: 3650, path: '/'});
        });

        it('returns "0" if not registered', function() {
          $.cookie('sgn', 0, {expires: 3650, path: '/'});
          wh.fire(obj);
          expect(obj.registration).toEqual(0);
        });

        it('returns "1" if registered', function() {
          $.cookie('sgn', 1, {expires: 3650, path: '/'});
          wh.fire(obj);
          expect(obj.registration).toEqual(1);
        });
      });

      it('sets the firing time', function () {
        wh.fire(obj);
        expect(obj.ft).toNotEqual(undefined);
      });
    });

    it ('firedTime returns the current time in epoch seconds', function() {
      now = new Date().getTime();
      expect(wh.firedTime()).toEqual(now);
    });

    it('#getItemId yields the id of the element', function() {
      testElement = $("<div id='foo'></div>");
      expect(wh.getItemId(testElement)).toEqual('foo');
    });

    it('#getItemId yields the first class of the element when no id present', function() {
      testElement = $("<div class='first second third'></div>");
      expect(wh.getItemId(testElement)).toEqual('first');
    });

    it('#firstClass yields the first class name of the element', function() {
      testElement = $("<div class='first second third'></div>");
      expect(wh.firstClass(testElement)).toEqual('first');
    });

    it('#getDataFromMetaTags extracts WH meta tags', function() {
      testDoc = $("<div><meta name='WH.test' content='dummy'/><meta name='WH.quiz' content='placeholder'</div>");
      result = { cg : '', test : 'dummy', quiz : 'placeholder' };
      expect(wh.getDataFromMetaTags(testDoc)).toEqual(result);
    });

    describe("#elemClicked", function() {
      var newContent;
      var targets;

      beforeEach(function() {
        newContent = $("<div><a class='link' href='#to_the_past'>Z</a></div>");
        targets = 'a.link';
        wh.init();
        wh.clickBindSelector = targets;
        wh.bindBodyClicked(newContent);
      });

      it('saves the last link clicked', function() {
        newContent.find('a.link').click();
        expect(wh.lastLinkClicked).toEqual("#to_the_past");
      });
    });

    describe("#init", function() {
      var newContent;
      var targets;

      beforeEach(function() {
        newContent = $("<div><a class='trap' href='#'>O</a><a class='x' href='#'>O</a></div>");
        targets = 'a.trap';
        wh.clickBindSelector = targets;
        wh.bindBodyClicked(newContent);
        spyOn(wh, 'fire');
      });

      it('binds to the named elements', function() {
        newContent.find('a.trap').click();
        expect(wh.fire).toHaveBeenCalled();
      });

      it('does not bind to other elements', function() {
        newContent.find('a.x').click();
        expect(wh.fire).not.toHaveBeenCalled();
      });
    });

    it('#setOneTimeData records attributes', function() {
      once = {a: 'Apple', b: 'Banana'};
      wh.setOneTimeData(once);
      data = wh.getOneTimeData();
      expect(data.a).toEqual('Apple');
      expect(data.b).toEqual('Banana');
    });

    describe("#setFollowHref", function() {
      it('defaults to true', function() {
        wh.setFollowHref();
        expect(wh.followHref).toEqual(true);
      });

      it('overrides default with argument', function() {
        wh.setFollowHref({followHref:false});
        expect(wh.followHref).toEqual(false);
      });
    });

    describe("#determineReferrer", function() {
      beforeEach(function() {
        testDocument = $('<div></div>');
        testDocument.referrer = "rawr";
        testWindow = $('<div></div>');
        testWindow.location = {
          href: ""
        };
      });

      it('should use real_referrer when use_real_referrer is true', function() {
        $.cookie('real_referrer', 'woof');
        testWindow.location.href = "http://www.rentpathsite.com/?use_real_referrer=true"
        expect(wh.determineReferrer(testDocument, testWindow)).toEqual("woof");
      });

      it('should use document.referrer when use_real_referrer is false', function() {
        $.cookie('real_referrer', 'woof');
        testWindow.location.href = "http://www.rentpathsite.com/?use_real_referrer=false"
        expect(wh.determineReferrer(testDocument, testWindow)).toEqual("rawr");
      });
    });
  });
});
