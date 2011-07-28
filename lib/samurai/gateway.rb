class Samurai::Gateway < Samurai::Base
  
  # Returns the default gateway specified by Samurai.gateway_token if you passed it into Samurai.setup_site.
  def self.the_gateway
    Samurai::Gateway.new(:id => Samurai.gateway_token)
  end
  
  # Convenience method that calls the purchase method on the default gateway.
  def self.purchase(*args)
    the_gateway.purchase(*args)
  end

  # Convenience method that calls the authorize method on the default gateway.
  def self.authorize(*args)
    the_gateway.authorize(*args)
  end
  
  # Convenience method to authorize and capture a payment_method for a particular amount in one transaction.
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # options:: an optional has of additional values to pass in accepted values are:
  # *+descriptor+:: descriptor for the transaction
  # *+custom+:: custom data, this data does not get passed to the gateway, it is stored within samurai.feefighters.com only
  # *+customer_reference+:: an identifier for the customer, this will appear in the gateway if supported
  # *+billing_reference::+ an identifier for the purchase, this will appear in the gateway if supported
  # Returns a Samurai::Transaction containing the gateway's response.
  def purchase(payment_method_token, amount, options = {})
    execute(:purchase, options.merge(:payment_method_token => payment_method_token, :amount => amount))
  end

  # Authorize a payment_method for a particular amount. 
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # options:: an optional has of additional values to pass in accepted values are:
  # *+descriptor+:: descriptor for the transaction
  # *+custom+:: custom data, this data does not get passed to the gateway, it is stored within samurai.feefighters.com only
  # *+customer_reference+:: an identifier for the customer, this will appear in the gateway if supported
  # *+billing_reference::+ an identifier for the purchase, this will appear in the gateway if supported
  # Returns a Samurai::Transaction containing the gateway's response.
  def authorize(payment_method_token, amount, options = {})
    execute(:authorize, options.merge(:payment_method_token => payment_method_token, :amount => amount))
  end
  
  private
  
  def execute(action, options = {})
    transaction = Samurai::Transaction.transaction_payload(options)
    # send a purchase request
    resp = post(action, {}, transaction)
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end
  
end