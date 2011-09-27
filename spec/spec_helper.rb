require 'rspec'
require 'ruby-debug'
require 'pp'
Debugger.start
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 5
Debugger.settings[:reload_source_on_change] = true

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SITE = ENV['site'] || 'https://api.samurai.feefighters.com/v1/'
USE_MOCK = !ENV['site']

PAYMENT_METHOD_TOKENS = {
  :success => 'b7c966452702282b32a4c65d'
}

RSpec.configure do |c|
  c.before :all do
    @seed = rand(1000).to_f / 100.0
  end
  c.before :each do
    @seed += 1.0
    ActiveResource::Base.logger.info self.example.description
  end
end

require 'samurai'
Samurai.options = {
  :site => SITE, 
  :merchant_key => ENV['merchant_key'] || 'f4b17359f267915e705fdcb6',
  :merchant_password => ENV['merchant_password'] || 'd7bf19a8aa1051335b83b349',
  :processor_token => ENV['processor_token'] || 'c5823b5f1616ed6c0891d167'
}



#
# Add more detailed response logging to ActiveResource
#
require 'logger'
ActiveResource::Base.logger = Logger.new(STDOUT)

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
