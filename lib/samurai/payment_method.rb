class Samurai::PaymentMethod < Samurai::Base
  
  include Samurai::CacheableByToken

  def id
    self.token
  end
  
  def token
    self.payment_method_token
  end
  
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
