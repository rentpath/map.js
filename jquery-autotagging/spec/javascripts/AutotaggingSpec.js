describe("Autotagging Suite", function() {
  var wh, simulPlatform, testWindow;

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
  });
});
