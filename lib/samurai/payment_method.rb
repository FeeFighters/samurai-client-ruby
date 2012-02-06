require 'active_resource/version'

# Samurai::PaymentMethod
# -----------------

# Samurai credit card tokenization, including retaining & redacting Payment Methods
class Samurai::PaymentMethod < Samurai::Base
  
  include Samurai::CacheableByToken

  def id
    self.token
  end
  
  # Alias for `payment_method_token`
  def token
    self.attributes["payment_method_token"]
  end
  
  # Retains the payment method on `api.samurai.feefighters.com`. Retain a payment method if
  # it will not be used immediately. 
  def retain
    resp = self.post(:retain, {}, '<payment_method></payment_method>')
    self.load_attributes_from_response(resp)
  end
  
  # Redacts sensitive information from the payment method, rendering it unusable.
  def redact
    resp = self.post(:redact, {}, '<payment_method></payment_method>')
    self.load_attributes_from_response(resp)
  end
  
  # Retrieves JSON formatted custom data that is encoded in the custom_data attribute
  def custom_json_data
    @custom_data ||= self.custom && (JSON.parse(self.custom) rescue {}).symbolize_keys
  end

  # Override base error processing with specific PaymentMethod behavior
  # Examine the `<messages>` array, and add an error to the Errors object for each `<message>`
  def process_response_errors
    if respond_to?(:messages) && self.messages
      # Sort the messages so that more-critical/relevant ones appear first, since only the first error is added to a field
      sorted_messages = self.messages.sort_by {|m| ['is_blank', 'not_numeric', 'too_short', 'too_long', 'failed_checksum'].index(m.key) || 0 }
      sorted_messages.each do |message|
        self.errors.add message.context, message.description if self.errors[message.context].blank?
      end
    end
  end
  protected :process_response_errors

  # Setup the PaymentMethod schema for ActiveResource, so that new objects contain empty attributes
  KNOWN_ATTRIBUTES = [
    :first_name, :last_name, :address_1, :address_2, :city, :state, :zip,
    :card_number, :cvv, :expiry_month, :expiry_year, :sandbox, :custom
  ]
  include Samurai::ActiveResourceSupport

  # Convenience method for preparing a new PaymentMethod for use with a transparent redirect form
  def self.for_transparent_redirect(params)
    if params[:payment_method_token].blank?
      Samurai::PaymentMethod.new(params)
    else
      Samurai::PaymentMethod.find(params[:payment_method_token]).tap do |pm|
        pm.card_number = "************#{pm.last_four_digits}"
        pm.cvv = "***"
        pm.errors.add :base, 'The card number or CVV are not valid.' if !pm.is_sensitive_data_valid
      end
    end
  end

end
