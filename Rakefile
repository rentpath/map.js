VERSION_STRING_REGEX = /"version":\s+"(\d+).(\d+).(\d+)(?:(-.+)?(\d+)?)?"/
VERSION_NUMBER_REGEX = /"version": "([\d\.\-a-zA-Z]+)",/

namespace :bump do
  [:major, :minor, :patch].each do |level|
    desc "Increment the #{level} version number of the given package"
    task level do
      ensure_valid_package
      bump_version(level)
    end
  end
end

desc "Tag and publish the package"
task :release do
  tag_package
  push_tag
  compile_coffee
  publish_to_jam
end

def package
  @package = ENV['package'] || ARGV.last
end

def ensure_valid_package
  abort_with_package_message unless valid_package?
end

def valid_package?
  File.directory?(package) && has_package_json?
end

def has_package_json?
  File.exists?(package_json)
end

def package_json
  @package_json ||= File.join(package, "package.json")
end

def abort_with_package_message
  abort("A valid package must be specified")
end

#TODO handle valid pre-release version numbers, if possible (See semver 2.0.0 spec)
def bump_version(level)
  package_json_contents = File.read(package_json)

  case level
  when :major
    package_json_contents.gsub!(VERSION_STRING_REGEX) { "\"version\": \"#{$1.to_i + 1}.0.0\"" }
  when :minor
    package_json_contents.gsub!(VERSION_STRING_REGEX) { "\"version\": \"#{$1}.#{$2.to_i + 1}.0\"" }
  when :patch
    package_json_contents.gsub!(VERSION_STRING_REGEX) { "\"version\": \"#{$1}.#{$2}.#{$3.to_i + 1}\"" }
  when :'pre-release'
    package_json_contents.gsub!(VERSION_STRING_REGEX) { "\"version\": \"#{$1}.#{$2}.#{$3}#{$4}#{$5.to_i + 1}\"" }
  else
  end

  File.open(package_json, 'w') { |f| f.write package_json_contents }
end

def tag_package
  puts "Creating tag: #{package}-v#{current_version}..."
  `git tag -a #{package}-v#{current_version} -m '#{package} version #{current_version}'`
end

def push_tag
  puts "Pushing newly created tag..."
  `git push --tags`
end

def compile_coffee
  puts "Compiling any coffeescript..."
  `coffee -c --output #{package}/ #{package}/src/`
end

def publish_to_jam
  puts "Publishing to jam server..."
  `jam publish --no-auth #{package}`
end

def current_version
  @current_version ||= File.read(package_json).match(VERSION_NUMBER_REGEX).captures.first
end

