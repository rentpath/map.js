define [ ], () ->

  describeMixin 'map/components/mixins/mobile_detection', ->
    beforeEach ->
      @setupComponent()

    it "should be defined", ->
      expect(@component).toBeDefined()

    describe 'detecting mobile browsers', ->
      it "should detect android mobile browsers", () ->
        expect(@component.isMobile('Some Android browser')).toBe(true)

      it "should detect apple mobile browsers", () ->
        expect(@component.isMobile('Some iPhone browser')).toBe(true)
        expect(@component.isMobile('Some iPad browser')).toBe(true)
        expect(@component.isMobile('Some iPod browser')).toBe(true)

      it "should detect blackberry mobile browsers", () ->
        expect(@component.isMobile('Some BlackBerry browser')).toBe(true)

      it "should detect opera mini mobile browsers", () ->
        expect(@component.isMobile('Some Opera Mini browser')).toBe(true)

      it "should detect opera IE mobile browsers", () ->
        expect(@component.isMobile('Some IEMobile browser')).toBe(true)

