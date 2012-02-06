# -*- encoding: utf-8 -*-
require File.expand_path("../lib/samurai/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "samurai"
  s.version     = Samurai::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Graeme Rouse", "Derek Zak"]
  s.email       = ["graeme@ubergateway.com", "derek@ubergateway.com"]
  s.homepage    = "http://rubygems.org/gems/samurai"
  s.summary     = "Integration gem for samurai.feefighters.com"
  s.description = "If you are an online merchant and using samurai.feefighters.com, this gem will make your life easy. Integrate with the samurai.feefighters.com portal and process transaction."

  s.required_rubygems_version = ">= 1.3.5"
  # s.rubyforge_project         = "samurai"
  
  #s.add_dependency "activeresource", "~> 2.3"  # use this line to test with activeresource 2.3.x
  s.add_dependency "activeresource", ">= 2.2.2"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", ">= 2.6.0"
  s.add_development_dependency 'fakeweb'
  if RUBY_VERSION =~ /^1\.9/
    s.add_development_dependency 'ruby-debug19'
  else
    s.add_development_dependency 'ruby-debug'
  end

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
