require 'net/http'
require 'uri'

module TransparentRedirectHelper

  def create_payment_method(params = {}, options={})
    url = Samurai.site + 'payment_methods'
    url.sub! %r{https://}, "https://#{Samurai.merchant_key}:#{Samurai.merchant_password}@"

    uri = URI.parse url
    req = Net::HTTP::Post.new uri.path
    req.set_form_data params
    req.basic_auth uri.user, uri.password

    res = Net::HTTP.new(uri.host, uri.port)
    res.use_ssl = true

    response = res.start {|http| http.request(req) }
    {
      :payment_method_token => response['Location'] && response['Location'].sub(%r{#{Regexp.escape params['redirect_url']}\?payment_method_token=}, ''),
      :response => response,
      :request => req,
    }
  end

end
