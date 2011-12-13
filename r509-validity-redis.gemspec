$:.push File.expand_path("../lib", __FILE__)
require "r509/Validity/Redis/Version"

spec = Gem::Specification.new do |s|
  s.name = 'r509-validity-redis'
  s.version = R509::Validity::Redis::VERSION
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = false
  s.summary = "A Validity::Writer and Validity::Checker for r509, implemented with a Redis backend"
  s.description = "A Validity::Writer and Validity::Checker for r509, implemented with a Redis backend"
  s.add_dependency 'r509'
  s.add_dependency 'redis'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'syntax'
  s.author = "Sean Schulte"
  s.email = "sirsean@gmail.com"
  s.homepage = "http://langui.sh"
  s.required_ruby_version = ">= 1.8.6"
  s.files = %w(README.md Rakefile) + Dir["{lib,script,spec,doc,cert_data}/**/*"]
  s.test_files= Dir.glob('test/*_spec.rb')
  s.require_path = "lib"
end

