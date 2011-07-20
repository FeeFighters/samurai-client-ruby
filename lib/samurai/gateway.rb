class Samurai::Gateway < Samurai::Base
  
  # Returns the default gateway specified by Samurai.gateway_token if you passed it into Samurai.setup_site.
  def self.the_gateway
    Samurai::Gateway.new(:id => Samurai.gateway_token)
  end
  
  # Convienince method that calls the purchase method on the defalt gateway.
  def self.purchase(*args)
    the_gateway.purchase(*args)
  end

  # Convienince method that calls the authorize method on the defalt gateway.
  def self.authorize(*args)
    the_gateway.authorize(*args)
  end
  
  # Convienience method to authorize and capture a payment_method for a particular amount in one transaction. 
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # +descriptor+:: optional descriptor for the transaction
  # +custom+:: optional custom data, this data does not get passed to the gateway, it is stored within samurai.feefighters.com only
  # Returns a Samurai::Transaction containing the gateway's response.
  def purchase(payment_method_token, amount, descriptor = nil, custom = nil)
    transaction = Samurai::Transaction.transaction_payload(:payment_method_token => payment_method_token, :amount => amount, :descriptor => descriptor, :custom => custom)
    # send a purchase request
    resp = post(:purchase, {}, transaction)
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end

  # Authorize a payment_method for a particular amount. 
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # +descriptor+:: optional descriptor for the transaction
  # +custom+:: optional custom data, this data does not get passed to the gateway, it is stored within samurai.feefighters.com only
  # Returns a Samurai::Transaction containing the gateway's response.
  def authorize(payment_method_token, amount, descriptor = nil, custom = nil)
    transaction = Samurai::Transaction.transaction_payload(:payment_method_token => payment_method_token, :amount => amount, :descriptor => descriptor, :custom => custom)
    resp = post(:authorize, {}, transaction)
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end
  
end