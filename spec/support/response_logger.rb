require "erb"

class ResponseLogger
  include ERB::Util

  def initialize(io)
    @io = io
    @io.puts "<!doctype html>"
    @io.puts "<html>"
  end

  def close!
    @io.puts "</html>"
  end

  def log(name, request, response)
    @io.puts "<div class='example'>"
    @io.puts "  <h3>#{h name}</h3>"
    @io.puts "  <div class='request'>"
    @io.puts "    <p>"
    @io.puts "      <span class='method'>#{h request[:method].to_s.upcase}</span>"
    @io.puts "      <span class='path'>#{h request[:path]}</span>"
    @io.puts "    </p>"
    @io.puts "    <p class='headers'>#{h request[:headers]}</p>"
    @io.puts "    <pre class='prettyprint lang-xml'><code>#{h request[:body]}</code></pre>" if request[:body]
    @io.puts "  </div>"
    @io.puts "  <div class='response'>"
    @io.puts "    <p class='status'>Status Code: <span>#{h response.code}</span></p>"
    @io.puts "    <pre class='prettyprint lang-xml'><code>#{h response.body}</code></pre>"
    @io.puts "  </div>"
    @io.puts "</div>"
  end

end

module ResponseLoggerHelper
  def log_http!
    @logger.log example.full_description.sub(/generate documentation/, '').titleize,
                Samurai::Base.connection.http.request,
                Samurai::Base.connection.http.response
  end

  def log_request_response! request, response
    @logger.log example.full_description.sub(/generate documentation/, '').titleize,
                request, response
  end
end