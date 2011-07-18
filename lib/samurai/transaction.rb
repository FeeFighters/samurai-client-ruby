class Samurai::Transaction < Samurai::Base

  include Samurai::CacheableByToken
  
  def id
    self.reference_id
  end
  
  def token
    transaction_token
  end
  
  def capture
    
  end
  
  def void
    
  end
  
  def credit
    
  end

end
