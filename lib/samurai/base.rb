begin
  require 'active_resource'
rescue LoadError
  require 'activeresource' # for older versions of activeresource
end

# Samurai::Base
# -----------------

# Base class that all Samurai ActiveResource models inherit from
# Provides some common error-handling functionality, as well as the AR site settings
class Samurai::Base < ActiveResource::Base
  self.format = ActiveResource::Formats::XmlFormat

  def self.setup_site!
    self.site = Samurai.site
    self.user = Samurai.merchant_key
    self.password = Samurai.merchant_password
  end

  def has_errors?
    respond_to?(:errors) && errors && errors.count > 0
  end

  protected

  def load_attributes_from_response(response)
    super
    process_response_errors
    self
  end
  def self.instantiate_record(record, prefix_options = {})
    super.tap { |instance| instance.send :process_response_errors }
  end

  def process_response_errors
    # Do nothing by default, subclasses may override this to process specific error messages
  end

  def transaction_errors_from_exception_response(e)
    return [] unless e && e.respond_to?(:response) && e.response && e.response.respond_to?(:body) && e.response.body
    doc = REXML::Document.new(e.response.body)
    errors = doc.root.elements['messages'].map do |message|
      message.attributes.inject({}) { |memo,(k,v)| memo.update(k=>v) } if message.is_a? REXML::Element
    end.compact
  end

end