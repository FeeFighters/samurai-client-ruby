# Samurai Gem
# -----------------

# Core Samurai Module
# Contains accessors for the important Samurai configuration settings
#
# To configure the Samurai gem:
#
# ```ruby
# require 'samurai'
# Samurai.options = {
#   :merchant_key => 'a1ebafb6da5238fb8a3ac9f6',
#   :merchant_password => 'ae1aa640f6b735c4730fbb56',
#   :processor_token => '69ac9c704329bb067d427bf0'
# }
# ```
module Samurai
  SITE = 'https://api.samurai.feefighters.com/v1/'
  DEFAULT_OPTIONS = {:site => SITE}

  # Gets the provider site that the gem is configured to hit
  def self.site # ::nodoc::
    @@options[:site]
  end
  
  def self.merchant_key # ::nodoc::
    @@options[:merchant_key]
  end
  
  def self.merchant_password # ::nodoc::
    @@options[:merchant_password]
  end
  
  def self.processor_token # ::nodoc::
    @@options[:processor_token]
  end
  
  def self.options
    @@options
  end
  
  def self.options=(value)
    @@options = (value || {}).reverse_merge(DEFAULT_OPTIONS)
    Samurai::Base.setup_site!
  end

end

# Require each of the samurai components
require 'samurai/cacheable_by_token'
require 'samurai/base'
require 'samurai/processor'
require 'samurai/payment_method'
require 'samurai/transaction'
require 'samurai/message'
require 'samurai/processor_response'
require 'samurai/rails'


# Monkey-patch AR::Base, because chunked encoding isn't handled properly
# see: https://github.com/jkrall/rails/commit/00920bb374a73626159e0002fe620f3aa4b5cfcf
#      https://github.com/rails/rails/pull/2079
module ActiveResource
  class Base
    protected
      def load_attributes_from_response(response)
        has_content_length = !response['Content-Length'].blank? && response['Content-Length'] != "0"
        has_body = !response.body.nil? && response.body.strip.size > 0
        is_chunked = response["Transfer-Encoding"] == "chunked"

        if has_body && (has_content_length || is_chunked)
          if [ActiveResource::VERSION::MAJOR, ActiveResource::VERSION::MINOR].compact.join('.').to_f < 3.1
            load(self.class.format.decode(response.body))
          else
            load(self.class.format.decode(response.body), true)
          end
          @persisted = true
        end
      end
  end
end