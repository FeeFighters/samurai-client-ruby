require 'rspec'
require 'pp'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SITE = ENV['site'] || 'https://api.samurai.feefighters.com/v1/'
USE_MOCK = !ENV['site']

RSpec.configure do |c|
  c.before :each do
    @seed = next_seed
    ActiveResource::Base.logger.info "---------------------------------------------"
    ActiveResource::Base.logger.info "--- " + self.example.description
    ActiveResource::Base.logger.info "---------------------------------------------"
  end
  c.include TransparentRedirectHelper
  c.include TransactionSeed
end

require 'samurai'
DEFAULT_OPTIONS = {
  :site => SITE,
  :merchant_key => ENV['merchant_key'] || 'a1ebafb6da5238fb8a3ac9f6',
  :merchant_password => ENV['merchant_password'] || 'ae1aa640f6b735c4730fbb56',
  :processor_token => ENV['processor_token'] || '5a0e1ca1e5a11a2997bbf912'
}
Samurai.options = DEFAULT_OPTIONS.clone


#
# Add more detailed response logging to ActiveResource
#
require 'logger'
ActiveResource::Base.logger = Logger.new(STDOUT)

if [ActiveResource::VERSION::MAJOR, ActiveResource::VERSION::MINOR].compact.join('.').to_f >= 3.0
  module ActiveResource
    class Connection
      private
        # Makes a request to the remote service.
        def request(method, path, *arguments)
          result = ActiveSupport::Notifications.instrument("request.active_resource") do |payload|
            payload[:method]      = method
            payload[:request_uri] = "#{site.scheme}://#{site.host}:#{site.port}#{path}"
            payload[:request_arguments] = arguments
            payload[:result]      = http.send(method, path, *arguments)
          end
          handle_response(result)
        rescue Timeout::Error => e
          raise TimeoutError.new(e.message)
        rescue OpenSSL::SSL::SSLError => e
          raise SSLError.new(e.message)
        end
    end
  end

  module ActiveResource
    class VerboseLogSubscriber < ActiveSupport::LogSubscriber
      def request(event)
        result = event.payload[:result]
        info "#{event.payload[:method].to_s.upcase} #{event.payload[:request_uri]}"
        event.payload[:request_arguments].each {|s| debug s }
        info "--> %d %s %d (%.1fms)" % [result.code, result.message, result.body.to_s.length, event.duration]
        debug result.body.to_s
      end

      def logger
        ActiveResource::Base.logger
      end
    end
  end

  ActiveSupport::Notifications.unsubscribe "request.active_resource"
  ActiveResource::VerboseLogSubscriber.attach_to :active_resource
end
