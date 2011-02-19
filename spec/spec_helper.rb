dir = File.dirname(File.expand_path(__FILE__))
$:.unshift(File.join(dir, '..', 'lib'))
$:.unshift(dir)

require 'rubygems'
require 'bundler/setup'
require 'open-uri'
require 'rspec'
require 'mocha'
require 'fakeweb'
require 'unindentable'
require 'http/wiretap'

# Configure RSpec
Rspec.configure do |c|
  c.mock_with :mocha
end
