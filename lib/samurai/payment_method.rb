class Samurai::PaymentMethod < Samurai::Base
  
  include Samurai::CacheableByToken

  def id # :nodoc:
    self.token
  end
  
  def token
    self.payment_method_token
  end
  
  # Retains the payment method on samurai.feefighters.com. Retain a payment method if 
  # it will not be used immediately. 
  def retain
    self.post(:retain)
  end
  
  def redact
    self.post(:redact)
  end
  
  def custom_data
    @custom_data ||= self.custom && (JSON.parse(self.custom) rescue {}).symbolize_keys
  end
end
