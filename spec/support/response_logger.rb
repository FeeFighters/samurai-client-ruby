require "erb"

class ResponseLogger
  include ERB::Util

  def initialize(io)
    @io = io
    @io.puts "<!doctype html>"
    @io.puts "<html>"
    @io.puts '<div class="wrapper">'
  end

  def close!
    @io.puts '</div>'
    @io.puts "</html>"
  end

  def log(name, request, response)
    @io.puts "<article class='example span-10 prepend-1'>"
    @io.puts "  <h3>#{h name}</h3>"
    @io.puts '  <div class="code http-request"><em class="lang">HTTP Request</em>'
    @io.puts "    <pre>#{h request[:method].to_s.upcase} #{h request[:path]}</pre>"
    @io.puts '  </div>'
    @io.puts "  <p class='headers'>#{h request[:headers]}</p>"
    if request[:body]
      @io.puts '  <div class="code xml">'
      @io.puts '    <em class="lang">XML</em>'
      @io.puts "    <pre class='prettyprint lang-xml'>#{h request[:body]}</pre>"
      @io.puts '  </div>'
    end
    @io.puts '  <div class="code http-response">'
    @io.puts "    <em class='lang'>HTTP Response: #{h response.code}</em>"
    @io.puts "    <pre class='prettyprint lang-xml'><code>#{h response.body}</code></pre>"
    @io.puts "  </div>"
    @io.puts "</article>"
    @io.puts "<hr>"
  end

end

module ResponseLoggerHelper
  def log_http!
    @logger.log example.full_description.sub(/generate documentation/, '').titleize,
                Samurai::Base.connection.http.request,
                Samurai::Base.connection.http.response
  end

  def log_request_response! request, response
    def request.[](v)
      case v
      when :method
        return self.method
      when :path
        return self.path
      when :headers
        return self.to_hash
      else
        super
      end
    end
    @logger.log example.full_description.sub(/generate documentation/, '').titleize,
                request, response
  end
end