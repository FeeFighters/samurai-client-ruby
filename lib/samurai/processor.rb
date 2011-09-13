class Samurai::Processor < Samurai::Base
  
  # Returns the default processor specified by Samurai.processor_token if you passed it into Samurai.setup_site.
  def self.the_processor
    Samurai::Processor.new(:id => Samurai.processor_token)
  end
  
  # Convenience method that calls the purchase method on the default processor.
  def self.purchase(*args)
    the_processor.purchase(*args)
  end

  # Convenience method that calls the authorize method on the default processor.
  def self.authorize(*args)
    the_processor.authorize(*args)
  end
  
  # Convenience method to authorize and capture a payment_method for a particular amount in one transaction.
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # options:: an optional has of additional values to pass in accepted values are:
  # *+descriptor+:: descriptor for the transaction
  # *+custom+:: custom data, this data does not get passed to the processor, it is stored within api.samurai.feefighters.com only
  # *+customer_reference+:: an identifier for the customer, this will appear in the processor if supported
  # *+billing_reference::+ an identifier for the purchase, this will appear in the processor if supported
  # Returns a Samurai::Transaction containing the processor's response.
  def purchase(payment_method_token, amount, options = {})
    execute(:purchase, options.merge(:payment_method_token => payment_method_token, :amount => amount))
  end

  # Authorize a payment_method for a particular amount. 
  # Parameters:
  # +payment_method_token+:: token identifying the payment method to authorize
  # +amount+:: amount to authorize
  # options:: an optional has of additional values to pass in accepted values are:
  # *+descriptor+:: descriptor for the transaction
  # *+custom+:: custom data, this data does not get passed to the processor, it is stored within api.samurai.feefighters.com only
  # *+customer_reference+:: an identifier for the customer, this will appear in the processor if supported
  # *+billing_reference::+ an identifier for the purchase, this will appear in the processor if supported
  # Returns a Samurai::Transaction containing the processor's response.
  def authorize(payment_method_token, amount, options = {})
    execute(:authorize, options.merge(:payment_method_token => payment_method_token, :amount => amount))
  end
  
  private
  
  def execute(action, options = {})
    transaction = Samurai::Transaction.transaction_payload(options)
    begin
      @persisted = true # keep AR 3.1 from using the new_ resource path

      # send a purchase request
      resp = post(action, {}, transaction)

      # return the response, wrapped in a Samurai::Transaction
      Samurai::Transaction.new.load_attributes_from_response(resp)

    rescue ActiveResource::BadRequest=>e
      # initialize a fresh transaction with the give options, add a generic error to it, and return it
      Samurai::Transaction.new(options.merge(:transaction_type=>action.to_s)).tap do |transaction|
        transaction.payment_method = Samurai::PaymentMethod.find options[:payment_method_token]
        transaction.created_at = Time.now
        transaction.processor_response = nil
        transaction.errors[:base] << "Invalid request."
      end
    end
  end
  
end