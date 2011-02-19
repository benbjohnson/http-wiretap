lib = File.expand_path('lib', File.dirname(__FILE__))
$:.unshift lib unless $:.include?(lib)

require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rake/testtask'
require 'http/wiretap'

#############################################################################
#
# Standard tasks
#
#############################################################################

task :console do
  sh "irb -rubygems -r ./lib/http/wiretap.rb"
end


#############################################################################
#
# Packaging tasks
#
#############################################################################

task :release do
  puts ""
  print "Are you sure you want to relase HTTP Wiretap #{HTTP::Wiretap::VERSION}? [y/N] "
  exit unless STDIN.gets.index(/y/i) == 0
  
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  
  # Build gem and upload
  sh "gem build http-wiretap.gemspec"
  sh "gem push http-wiretap-#{HTTP::Wiretap::VERSION}.gem"
  sh "rm http-wiretap-#{HTTP::Wiretap::VERSION}.gem"
  
  # Commit
  sh "git commit --allow-empty -a -m 'v#{HTTP::Wiretap::VERSION}'"
  sh "git tag v#{HTTP::Wiretap::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{HTTP::Wiretap::VERSION}"
end
