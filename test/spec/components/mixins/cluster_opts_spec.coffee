define [ ], () ->

  describeMixin 'map/components/mixins/cluster_opts', ->
    beforeEach ->
      @setupComponent()

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe "#clusterStyles", ->
      describe "with preset values", ->
        styles = {}
        attrs = {}
        beforeEach ->
          styles = @component.clusterStyles()
          attrs = @component.attributes()

        it "should return the preset URL", ()->
          expect(styles.url).toBe(attrs.clusterURL)

        it "should return the preset height", ()->
          expect(styles.height).toBe(attrs.clusterHeight)

        it "should return the preset width", ()->
          expect(styles.width).toBe(attrs.clusterWidth)

        it "should return the preset text color", ()->
          expect(styles.textColor).toBe(attrs.clusterTextColor)

        it "should return the preset text size", ()->
          expect(styles.textSize).toBe(attrs.clusterTextSize)

        it "should return the preset font weight", ()->
          expect(styles.fontWeight).toBe(attrs.clusterFontWeight)
