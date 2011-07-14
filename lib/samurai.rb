module Samurai

  mattr_accessor :site
  @@site = case Rails.env
    when 'development'
      'http://localhost:3002'
    when 'staging'
      'http://staging.api.ubergateway.com'
    else
      'http://api.ubergateway.com'
    end << '/v1/'
  
  mattr_accessor :merchant_key
  @@merchant_key = nil
  
  mattr_accessor :merchant_password
  @@merchant_password = nil
  
  mattr_accessor :gateway_token
  @@gateway_token = nil
  
  def self.setup_site(site, merchant_key, merchant_password, gateway_token = nil)
    site += '/v1/' unless site =~ /\/v1\/$/
    @@site = site
    @@merchant_key = merchant_key
    @@merchant_password = merchant_password
    @@gateway_token = gateway_token if gateway_token
    Samurai::Base.setup_site!
  end
  
end

require 'samurai/base'
require 'samurai/gateway'
require 'samurai/payment_method'
require 'samurai/transaction'
