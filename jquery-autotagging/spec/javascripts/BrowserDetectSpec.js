describe("Autotagging Suite", function() {
  var bd;
  var dummyWindow;

  beforeEach(function() {
    var ready = false;
    var dummyWindow = {
      navigator: {
        userAgent:  {string: ''},
        appVersion: {string: ''}
      }
    };

    require(['../../lib/browserdetect'], function(BD) {
      bd = BD;
      ready = true;
    });

    waitsFor(function(){
      return ready;
    });
  });

  describe("Instance Methods", function() {
    it('finds platform', function () {
      platform = bd.platform();
      expect(platform.browser).toEqual('Chrome');
    });
  });
});
