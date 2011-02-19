# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'http/wiretap'

Gem::Specification.new do |s|
  s.name        = 'http-wiretap'
  s.version     = HTTP::Wiretap::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Ben Johnson']
  s.email       = ['benbjohnson@yahoo.com']
  s.homepage    = 'http://github.com/benbjohnson/http-wiretap'
  s.summary     = 'An HTTP Recorder'

  s.add_development_dependency('rspec', '~> 2.4.0')
  s.add_development_dependency('mocha', '~> 0.9.12')
  s.add_development_dependency('fakeweb', '~> 1.3.0')
  s.add_development_dependency('unindentable', '~> 0.1.0')

  s.test_files   = Dir.glob('test/**/*')
  s.files        = Dir.glob('lib/**/*') + %w(README.md)
  s.require_path = 'lib'
end
