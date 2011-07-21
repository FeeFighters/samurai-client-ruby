begin
  require 'active_resource'
rescue LoadError
  require 'activeresource' # for older versions of activeresource
end
class Samurai::Base < ActiveResource::Base

  def self.setup_site! # :nodoc:
    self.site = Samurai.site
    self.user = Samurai.merchant_key
    self.password = Samurai.merchant_password
  end
  
end