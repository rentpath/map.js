describe("Autotagging Suite", function() {
  var wh, testWindow;

  beforeEach(function() {
    var ready = false;

    require(['../../jquery.autotagging'], function(WH) {
      wh = new WH();
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

    it('#firstClass yields the first class name of the element', function() {
      testElement = $("<div class='first second third'></div>");
      expect(wh.firstClass(testElement)).toEqual('first');
    });

    it('#getDataFromMetaTags extracts WH meta tags', function() {
      testDoc = $("<div><meta name='WH.test' content='dummy'/><meta name='WH.quiz' content='placeholder'</div>");
      result = { cg : '', test : 'dummy', quiz : 'placeholder' };
      expect(wh.getDataFromMetaTags(testDoc)).toEqual(result);
    });

    describe("#fire", function() {
      beforeEach(function() {
        callback = {
          fightFire: function(obj) {
            obj.blaze = true;
          }
        };

        wh.fireCallback = callback.fightFire;
        wh.platform = {OS: 'OS', browser: 'dummy', version: ''};
        spyOn(callback, 'fightFire');
      });

      it('calls the given callback', function () {
        wh.fire({});
        expect(callback.fightFire).toHaveBeenCalled();
      });
    });
  });

  // describe("Support for Callbacks", function() {
  //   it('is called after fire', function() {

  //   });
  // });
});
