class Samurai::Base < ActiveResource::Base
  
  def self.setup_site!
    self.site = Samurai.site
    self.user = Samurai.merchant_key
    self.password = Samurai.merchant_password
  end
  
end