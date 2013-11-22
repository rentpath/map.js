describe "ImageHelper", ->

  imageHelper = null

  beforeEach ->
    ready = false

    require ['../../image-helper', 'jasmine-jquery'], (_imageHelper) ->
      imageHelper = _imageHelper
      loadFixtures("image-helper.html")
      ready = true

    waitsFor ->
      return ready

  describe "#pickImageServer", ->

    it "rotates servers", ->
      expect(imageHelper.pickImageServer()).toBe 1
      expect(imageHelper.pickImageServer()).toBe ""

  describe "#assetURL", ->

    it "pulls content from the meta tag", ->
      expect(imageHelper.assetURL()).toBe "http://local.apartmentguide.com"

  describe "#notFoundURL", ->

    beforeEach ->

    it "builts it with the host", ->
      expect(imageHelper.notFoundURL()).toBe "http://local.apartmentguide.com/images/prop_no_photo_results.png"

  describe "#isInvalidURL", ->

    it "is not when a string", ->
      expect(imageHelper.isInvalidURL("foo.png")).toBeFalsy()

    it "is when undefined", ->
      expect(imageHelper.isInvalidURL()).toBeTruthy()

    it "is when undefined", ->
      expect(imageHelper.isInvalidURL("")).toBeTruthy()

  describe "#url", ->

    it "appends width and height to a single url", ->
      expect(imageHelper.url("foo",10,20)).toBe "http://image1.apartmentguide.com/foo/10-20"

    it "appends width to a url", ->
      expect(imageHelper.url("foo",10)).toBe "http://image.apartmentguide.com/foo/10-"

    it "appends height to a url", ->
      expect(imageHelper.url("foo",null,20)).toBe "http://image1.apartmentguide.com/foo/-20"

    it "accepts an array of objects and uses the first", ->
      examples = [ { path: "foo" }, { path: "bar" } ]
      expect(imageHelper.url(examples,10,20)).toBe "http://image.apartmentguide.com/foo/10-20"

    it "appends width and height to a url with query params", ->
      expect(imageHelper.url("foo?a=b",10,20)).toBe "http://image1.apartmentguide.com/foo/10-20?a=b"

    it "does not require width or height", ->
      expect(imageHelper.url("foo")).toBe "http://image.apartmentguide.com/foo/"

    it "returns a not found when image is invalid", ->
      expect(imageHelper.url("")).toBe imageHelper.notFoundURL()
