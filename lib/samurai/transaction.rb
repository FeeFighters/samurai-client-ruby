# Samurai::Transaction
# -----------------

# This class represents a Samurai Transaction
# It can be used to query Transactions & capture/void/credit/reverse
class Samurai::Transaction < Samurai::Base
  include Samurai::CacheableByToken

  # Alias for `transaction_token`
  def id
    transaction_token
  end
  alias_method :token, :id

  # Captures an authorization. Optionally specify an `amount` to do a partial capture of the initial
  # authorization. The default is to capture the full amount of the authorization.
  def capture(amount = nil, options = {})
    execute(:capture, {:amount => amount || self.amount}.reverse_merge(options))
  end

  # Void this transaction. If the transaction has not yet been captured and settled it can be voided to
  # prevent any funds from transferring.
  def void(options = {})
    execute(:void, options)
  end

  # Create a credit or refund against the original transaction.
  # Optionally accepts an `amount` to credit, the default is to credit the full
  # value of the original amount
  def credit(amount = nil, options = {})
    execute(:credit, {:amount => amount || self.amount}.reverse_merge(options))
  end

  # Reverse this transaction.  First, tries a void.
  # If a void is unsuccessful, (because the transaction has already settled) perform a credit for the full amount.
  def reverse(amount = nil, options = {})
    execute(:reverse, {:amount => amount || self.amount}.reverse_merge(options))
  end

  def success?
    respond_to?(:processor_response) && processor_response && processor_response.success
  end
  alias_method :success, :success?
  def failed?
    !success?
  end

  private

  # Make the actual ActiveResource POST request, process the response
  def execute(action, options = {})
    begin
      resp = post(action, {}, self.class.transaction_payload(options))
      # return the response, wrapped in a Samurai::Transaction
      Samurai::Transaction.new.load_attributes_from_response(resp)
    rescue ActiveResource::BadRequest=>e
      # initialize a fresh transaction with the give options, add a generic error to it, and return it
      Samurai::Transaction.new(options.merge(:transaction_type=>action.to_s)).tap do |transaction|
        transaction.created_at = Time.now
        transaction.processor_response = nil
        transaction.errors[:base] << "Invalid request."
      end
    end
  end

  # Override base error processing with specific Transaction behavior
  # Examine the `<processor_response><messages>` array, and add an error to the Errors object for each `<message>`
  def process_response_errors
    _messages = []
    _messages += processor_response.messages if respond_to?(:processor_response) && processor_response.respond_to?(:messages)
    _messages += payment_method.messages if payment_method
    _messages.each do |message|
      if message.subclass == 'error'
        self.errors.add message.context, message.description
      end
    end
  end
  protected :process_response_errors

  # Builds an xml payload that represents the transaction data to submit to api.samurai.feefighters.com
  def self.transaction_payload(options = {})
    {
      :amount => options[:amount],
      :type => options[:type],
      :payment_method_token => options[:payment_method_token],
      :currency_code => options[:currency_code] || (options[:payment_method_token] && 'USD'), # currency code is only required for payloads that include the PMT
      :descriptor => options[:descriptor],
      :custom => options[:custom],
      :customer_reference => options[:customer_reference],
      :billing_reference => options[:billing_reference]
    }.
      reject{ |k,v| v.nil? }.
      to_xml(:skip_instruct => true, :root => 'transaction', :dasherize => false)
  end

  # Setup the Transaction schema for ActiveResource, so that new objects contain empty attributes
  KNOWN_ATTRIBUTES = [
    :amount, :type, :payment_method_token, :currency_code,
    :description, :custom, :customer_reference, :billing_reference, :processor_response,
    :descriptor_name, :descriptor_phone
  ]
  if [ActiveResource::VERSION::MAJOR, ActiveResource::VERSION::MINOR].compact.join('.').to_f < 3.1
    # If we're using ActiveResource pre-3.1, there's no schema class method, so we resort to some tricks...
    # Initialize the known attributes from the schema as empty strings, so that they can be accessed via method-missing
    EMPTY_ATTRIBUTES = KNOWN_ATTRIBUTES.inject(HashWithIndifferentAccess.new) {|h, k| h[k] = ''; h}
    def initialize(attrs={})
      super(EMPTY_ATTRIBUTES.merge(attrs))
    end
  else
    # Post AR 3.1, we can use the schema method to define our attributes
    schema do
      string *KNOWN_ATTRIBUTES
    end
  end

end
