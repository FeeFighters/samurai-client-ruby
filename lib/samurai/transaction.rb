class Samurai::Transaction < Samurai::Base
  
  include Samurai::CacheableByToken
  
  # Alias for transaction_token
  def id # :nodoc:
    transaction_token
  end
  alias_method :token, :id
  
  # Captures an authorization. Optionally specify an +amount+ to do a partial capture of the initial
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
  # Optionally accepts an +amount+ to credit, the default is to credit the full 
  # value of the original amount
  def credit(amount = nil, options = {})
    execute(:credit, {:amount => amount || self.amount}.reverse_merge(options))
  end

  # Reverse this transaction.  First, tries a void.
  # If a void is unsuccessful, (because the transaction has already settled) perform a credit for the full amount.
  def reverse(options = {})
    transaction = void(options)
    return transaction if transaction.processor_response.success
    return credit(nil, options)
  end

  def success?
    respond_to?(:processor_response) && processor_response.success
  end
  def failed?
    !success?
  end

  private
  
  def execute(action, options = {})
    resp = post(action, {}, self.class.transaction_payload(options))
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end

  def process_response_errors
    if self.processor_response && self.processor_response.messages
      self.processor_response.messages.each do |message|
        if message.subclass == 'error'
          self.errors.add message.context.gsub(/\./, ' '), message.key
        end
      end
    end
  end
  protected :process_response_errors

  # Builds an xml payload that represents the transaction data to submit to samurai.feefighters.com
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

  # Initialize the known attributes from the schema as empty strings, so that they can be accessed via method-missing
  KNOWN_ATTRIBUTES = [
    :amount, :type, :payment_method_token, :currency_code,
    :descriptor, :custom, :customer_reference, :billing_reference
  ]
  EMPTY_ATTRIBUTES = KNOWN_ATTRIBUTES.inject({}) {|h, k| h[k] = ''; h}
  def initialize(attrs={})
    super(EMPTY_ATTRIBUTES.merge(attrs))
  end


  require 'pathname'
  def self.form_html
    File.read(form_partial_path)
  end
  def self.form_partial_path
    Pathname.new(__FILE__).dirname.join('..', '..', 'app', 'views', 'application', '_transaction_form.html.erb')
  end
  def self.show_html
    File.read(show_partial_path)
  end
  def self.show_partial_path
    Pathname.new(__FILE__).dirname.join('..', '..', 'app', 'views', 'application', '_transaction.html.erb')
  end

end
