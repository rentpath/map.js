describe("Tracker Suite", function() {
  var tracker, backupTracker, key, base, path, path_and_query;
  base = "/apartments/Alaska/Yakutat/";
  key = path = "/apartments/Alaska/Yakutat/1-beds-1-baths-1-star-rating-1z141xt+1z141xu+4lt/";
  path_and_query = "/apartments/Alaska/Yakutat/1-beds-1-baths-1-star-rating-1z141xt+1z141xu+4lt/?&sort=ratings-desc&page=1";

  var checkStorage = function(field, id) {
    if (id == null) id = path;
    var item = JSON.parse(localStorage.getItem(id));
    if(field) return item[field] || null;
    return item;
  };

  var resetTracker = function() {
    tracker.path = backupTracker.path;
    tracker.path_refinements = backupTracker.path_refinements;
  };

  beforeEach(function() {
    var ready = false;

    require(['jquery', '../../tracker'], function($, localTracker) {

      $('head').append('<meta class="pageInfo" content="search" name="type">');
      $('head').append('<meta class="pageInfo" content="city" name="searchType">');
      $('head').append('<meta class="pageInfo" content="1z141xt,1z141xu,4lt" name="nodes">');
      $('head').append('<meta class="pageInfo" content="1-beds-1-baths-1-star-rating-1z141xt+1z141xu+4lt" name="refinements">');

      tracker = localTracker;

      backupTracker = { path: tracker.path,
                        path_refinements: tracker.path_refinements};

      tracker.path = function() { return path };

      ready = true;
    });

    waitsFor(function(){
      return ready;
    });
  });

  describe("Public Module Functions", function() {
    describe("#key", function() {
      it("should return the refined search path by default", function() {
        expect(tracker.key()).toEqual('/apartments/Alaska/Yakutat/1-beds-1-baths-1-star-rating-1z141xt+1z141xu+4lt/')
      });
      it("should return the base search path", function() {
        expect(tracker.key("base")).toEqual('/apartments/Alaska/Yakutat/')
      });
      it("should return the base search path regardless of whether there are refinements to strip", function() {
        tracker.path = function() { return base };
        tracker.path_refinements = function() { return null };

        expect(tracker.key("base")).toEqual('/apartments/Alaska/Yakutat/')

        resetTracker();
      });
    });

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

    describe("#save", function() {
      localStorage.clear();

      it('should save page info', function () {
        tracker.track('something', 12);
        var page = checkStorage();

        expect(page['type']).toEqual('search');
        expect(page['searchType']).toEqual('city');
        expect(page['nodes']).toEqual(['1z141xt','1z141xu','4lt']);
      });

      it('should save an arbitrary item', function () {
        tracker.save('something', 12);
        expect(checkStorage('something')).toEqual(12);
      });

      it('should save an arbitrary item under a different key', function () {
        tracker.save('something else', 12, 'base');
        expect(checkStorage('something else', base)).toEqual(12);
      });
    });

    describe("#peek", function() {
      localStorage.clear();

      it('should return 0 (by default) for a missing item', function () {
        localStorage.clear();
        expect(tracker.peek('something')).toEqual(0);
      });

      it('should return passed-in for a missing item', function () {
        var default_value = "nothing";
        expect(tracker.peek('something', default_value)).toEqual(default_value);
      });

      it('should return an existent item', function () {
        var str = JSON.stringify({'something':1});
        localStorage.setItem(key, str)

        expect(tracker.peek('something')).toEqual(1);
      });

      it('should return an existent item from a different key', function () {
        var str = JSON.stringify({'another thing':100});
        localStorage.setItem(base, str)

        expect(tracker.peek('another thing', 0, 'base')).toEqual(100);
      });
    });

    describe("#number_of_visits", function() {
      it('should return 0 for an unstarted count', function () {
        localStorage.clear();
        expect(tracker.peek('count')).toEqual(0);
      });

      it('should return the count of visits', function () {
        tracker.track();
        expect(tracker.number_of_visits()).toEqual(1);
      });
    });

    describe("#refinements", function() {
      it('should return [] for absent nodes', function () {
        localStorage.clear();
        expect(tracker.refinements()).toEqual([]);
      });

      it('should return the list of nodes', function () {
        tracker.track();
        expect(tracker.refinements()).toEqual(['1z141xt','1z141xu','4lt']);
      });
    });

    describe("#number_of_refinements", function() {
      it('should return 0 for absent nodes', function () {
        localStorage.clear();
        expect(tracker.number_of_refinements()).toEqual(0);
      });

      it('should only return the number of nodes', function () {
        tracker.track();
        expect(tracker.number_of_refinements()).toEqual(3);
      });
    });

    describe("#type", function() {
      it('should return an empty string for a missing field', function () {
        localStorage.clear();
        expect(tracker.type()).toEqual('');
      });

      it('should return the page type', function () {
        tracker.track();
        expect(tracker.type()).toEqual('search');
      });
    });

    describe("#searchType", function() {
      it('should return an empty string for a missing field', function () {
        localStorage.clear();
        expect(tracker.searchType()).toEqual('');
      });

      it('should return the search type', function () {
        tracker.track();
        expect(tracker.searchType()).toEqual('city');
      });
    });

  });
});
