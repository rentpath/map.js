describe("Tracker Suite", function() {
  var tracker, key;

  var checkStorage = function(field) {
    var item = JSON.parse(localStorage.getItem(key));
    return item[field] || null;
  };

  beforeEach(function() {
    var ready = false;
    var key = "/apartments/Alaska/Yakutat/";

    localStorage.clear();

    require(['../../tracker'], function(localTracker) {
      tracker = localTracker;

      tracker.key = function() { key };

      ready = true;
    });

    waitsFor(function(){
      return ready;
    });
  });

  describe("Public Static Methods", function() {
    describe("#track", function() {
      it('should increment the count', function () {
        tracker.track();
        expect(checkStorage('count')).toEqual('1');
      });
    });
  });
});
