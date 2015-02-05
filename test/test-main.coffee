allTestFiles = []
TEST_REGEXP = /(spec|test)\.js$/i
pathToModule = (path) ->
  path.replace(/^\/base\//, "").replace /\.js$/, ""

Object.keys(window.__karma__.files).forEach (file) ->

  # Normalize paths to RequireJS module names.
  allTestFiles.push pathToModule(file) if TEST_REGEXP.test(file)
  return

require.config

  # Karma serves files under /base, which is the basePath from your config file
  baseUrl: "/base"

  paths: {
    map: 'src'
    flight: 'app/bower_components/flight'
    jquery: 'app/bower_components/jquery/jquery'
  }

  # dynamically load all test files
  deps: allTestFiles

  # we have to kickoff jasmine, as it is asynchronous
  callback: window.__karma__.start

# Uncomment to load flight fixtures.
# window.jasmine.getFixtures().fixturesPath = 'base/test/spec/fixtures/'
