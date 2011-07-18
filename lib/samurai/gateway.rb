class Samurai::Gateway < Samurai::Base
  
  def self.the_gateway
    Samurai::Gateway.new(:id => Samurai.gateway_token)
  end
  
  def purchase(payment_method_token, amount, descriptor)
    # send a purchase request
    resp = post(:purchase, 
      :transaction => {
        :amount => amount, 
        :type => 'purchase', 
        :payment_method_token => payment_method_token, 
        :currency_code => 'USD',
        :descriptor => descriptor
      }
    )
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end

  # TODO implement this functionality
  # def authorize
  #   post(:authorize)
  # end
  
end