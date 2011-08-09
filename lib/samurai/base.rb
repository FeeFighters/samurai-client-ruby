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

  protected

  def load_attributes_from_response(response)
    super.tap { |instance| instance.process_response_errors }
  end

  def process_response_errors
    # Do nothing by default, subclasses may override this to process specific error messages
  end

end