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
  
  private
  
  def execute(action, options = {})
    resp = post(action, {}, self.class.transaction_payload(options))
    # return the response, wrapped in a Samurai::Transaction
    Samurai::Transaction.new.load_attributes_from_response(resp)
  end

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
