describe("Tracker Suite", function() {
  var tracker, key;

  var checkStorage = function(field) {
    var item = JSON.parse(localStorage.getItem(key));
    return item[field] || null;
  };

  beforeEach(function() {
    var ready = false;
    var key = "/apartments/Alaska/Yakutat/";

    require(['../../tracker'], function(localTracker) {
      tracker = localTracker;

      tracker.key = function() { key };

      ready = true;
    });

    waitsFor(function(){
      return ready;
    });
  });

  describe("Public Module Functions", function() {
    describe("#track", function() {
      localStorage.clear();

      it('should start the count', function () {
        tracker.track();
        expect(checkStorage('count')).toEqual(1);
      });
      it('should increase the count', function () {
        tracker.track();
        expect(checkStorage('count')).toEqual(2);
      });
    });
  });
});
