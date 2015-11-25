define [ ], () ->

  describeMixin 'map/components/mixins/cluster_opts', ->
    beforeEach ->
      @fixture = readFixtures('map_utils.html')
      @setupComponent(@fixture, {mapPinCluster: 'http://localhost/images/nonsprite/map/map_cluster_red4.png'})

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe "#clusterStyles", ->
      describe "with preset values", ->
        styles = {}
        beforeEach ->
          styles = @component.clusterStyleArray()[0]

        it "should return the preset URL", ()->
           expect(styles.url).toBe('http://localhost/images/nonsprite/map/map_cluster_red4.png')

        it "should return the preset height", ()->
          expect(styles.height).toBe(40)

        it "should return the preset width", ()->
          expect(styles.width).toBe(46)

        it "should return the preset text color", ()->
          expect(styles.textColor).toBe('black')

        it "should return the preset text size", ()->
          expect(styles.textSize).toBe(11)

        it "should return the preset font weight", ()->
          expect(styles.fontWeight).toBe('bold')

        it "should return the preset font family", ()->
          expect(styles.fontFamily).toBe('Arial,sans-serif')

      describe "with override values", ->
        beforeEach ->
          @setupComponent(@fixture,
            {
              mapPinCluster: 'http://localhost/foo'
              clusterHeight: 50
              clusterWidth: 55
              clusterTextColor: 'red'
              clusterTextSize: 14
              clusterFontWeight: 'normal'
              clusterFontFamily: 'Helvetica'
              clusterSize: 5
            })


          @styles = @component.clusterStyleArray()[0]

        it "should return the preset URL", ()->
          expect(@styles.url).toBe('http://localhost/foo')

        it "should return the overridden height", ()->
          expect(@styles.height).toBe(50)

        it "should return the overridden width", ()->
          expect(@styles.width).toBe(55)

        it "should return the overridden text color", ()->
          expect(@styles.textColor).toBe('red')

        it "should return the overridden text size", ()->
          expect(@styles.textSize).toBe(14)

        it "should return the overridden font weight", ()->
          expect(@styles.fontWeight).toBe('normal')

        it "should return the overridden font family", ()->
          expect(@styles.fontFamily).toBe('Helvetica')

    describe "#clusterSize", ->
      describe "with preset value", ->
        it "should return the preset cluster size", ()->
          expect(@component.clusterSize()).toBe(10)

      describe "with override value", ->
        beforeEach ->
          @setupComponent(@fixture, { clusterSize: 5 })
        it "should return the overridden cluster size", ()->
          expect(@component.clusterSize()).toBe(5)

    describe "#clusterStyleArray", ->
      it "should be the correct length for the marker cluster api", ()->
        expect(@component.clusterStyleArray().length).toBe(5)
