require "erb"

class ResponseLogger
  include ERB::Util

  def initialize(io)
    @sections = []
    @io = io
    @io.puts '<div class="wrapper">'
  end

  def close!
    @io.puts '</div>'
    @sections.each do |section|
      @io.puts "<a href='##{section[:id]}'>#{section[:name]}</a><br>"
    end
  end

  def begin_section(name)
    @sections << {:name=>name, :id=>h(name.parameterize)}
    @io.puts "<article class='example span-8' id='#{h name.parameterize}'>"
    @io.puts "  <h3>#{h name}</h3>"
  end

  def end_section
    @io.puts "</article>"
    @io.puts "<hr>"
  end

  def log(request, response, options={})
    @io.puts '  <div class="code http-request"><em class="lang">HTTP Request</em>'
    @io.puts "    <pre><strong>#{h request[:method].to_s.upcase} #{h request[:path]}</strong><br>"
    @io.puts "Headers: #{h request[:headers].inject({}) {|h, (k,v)| h[k] = (v.is_a?(Array) ? v.first : v); h }}</pre>"
    @io.puts '  </div>'
    if request[:body]
      @io.puts '  <div class="code xml">'
      @io.puts '    <em class="lang">XML Payload</em>'
      @io.puts "    <pre class='prettyprint lang-xml'>#{h request[:body]}</pre>"
      @io.puts '  </div>'
    end
    @io.puts '  <div class="code http-response">'
    @io.puts "    <em class='lang'>HTTP Response: #{h response.code}</em>"
    @io.puts "    <pre class='prettyprint lang-xml'><code>#{h response.body}</code></pre>"
    @io.puts "  </div>"
  end

end

module ResponseLoggerHelper
  def log_http! options={}
    @logger.log Samurai::Base.connection.send(:http).request,
                Samurai::Base.connection.send(:http).response,
                options
  end

  def log_request_response! request, response, options={}
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
    @logger.log request, response, options
  end
end