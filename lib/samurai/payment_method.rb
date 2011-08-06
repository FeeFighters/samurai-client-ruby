class Samurai::PaymentMethod < Samurai::Base
  
  include Samurai::CacheableByToken

  def id # :nodoc:
    self.token
  end
  
  # Alias for +payment_method_token+
  def token
    self.payment_method_token
  end
  
  # Retains the payment method on samurai.feefighters.com. Retain a payment method if 
  # it will not be used immediately. 
  def retain
    self.post(:retain)
  end
  
  # Redacts sensitive information from the payment method, rendering it unusable.
  def redact
    self.post(:redact)
  end
  
  # Retrieves JSON formatted custom data that is encoded in the custom_data attribute
  def custom_json_data
    @custom_data ||= self.custom && (JSON.parse(self.custom) rescue {}).symbolize_keys
  end


  require 'pathname'
  def self.form_html
    File.read(form_partial_path)
  end
  def self.form_partial_path
    Pathname.new(__FILE__).dirname.join('..', '..', 'app', 'views', 'application', '_payment_method_form.html.erb')
  end

end
