# Author::    Graeme Rouse
# Copyright:: Copyright (c) 2011 Arizona Bay, LLC

module Samurai
  SITE = 'https://samurai.feefighters.com/v1/'
  DEFAULT_OPTIONS = {:site => SITE}

  # Gets the provider site that the gem is configured to hit
  def self.site # ::nodoc::
    @@options[:site]
  end
  
  def self.merchant_key # ::nodoc::
    @@options[:merchant_key]
  end
  
  def self.merchant_password # ::nodoc::
    @@options[:merchant_password]
  end
  
  def self.processor_token # ::nodoc::
    @@options[:processor_token]
  end
  
  def self.options
    @@options
  end
  
  def self.options=(value)
    @@options = (value || {}).reverse_merge(DEFAULT_OPTIONS)
    Samurai::Base.setup_site!
  end
  
end

require 'samurai/cacheable_by_token'
require 'samurai/base'
require 'samurai/processor'
require 'samurai/payment_method'
require 'samurai/transaction'
require 'samurai/message'
