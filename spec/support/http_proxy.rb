require 'active_resource/connection'

class HttpProxy
  attr_accessor :request, :response

  def initialize(http, options={})
    @http = http
    @response = nil
    @request = {}
  end

  def method_missing(meth, *args, &block)
    case meth
    when :post, :put
      @request = {
        :method => meth,
        :path => args[0],
        :body => args[1],
        :headers => args[2],
      }
    when :get, :delete
      @request = {
        :method => meth,
        :path => args[0],
        :headers => args[1],
      }
    end
    @response = @http.send(meth, *args, &block)
  end

  def respond_to?(meth)
    super || @http.respond_to?(meth)
  end
end

class HttpProxyConnection < ActiveResource::Connection
  def http
    @http ||= HttpProxy.new(configure_http(new_http))
  end
end
