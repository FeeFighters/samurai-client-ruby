require 'net/http'
require 'uri'

module TransparentRedirectHelper

  def create_payment_method(params = {}, options={})
    url = Samurai.site + 'payment_methods'
    url.sub! %r{://}, "://#{Samurai.merchant_key}:#{Samurai.merchant_password}@"

    uri = URI.parse url
    req = Net::HTTP::Post.new uri.path
    req.set_form_data params
    req.basic_auth uri.user, uri.password

    res = Net::HTTP.new(uri.host, uri.port)
    res.use_ssl = true if url =~ /https/

    puts "---------------------------------------"
    puts "-- #{uri.inspect} "
    puts "-- Body:\n#{req.body}"
    puts "--------"

    response = res.start {|http| http.request(req) }
    {
      :payment_method_token => response['Location'] && response['Location'].sub(%r{#{Regexp.escape params['redirect_url']}\?payment_method_token=}, ''),
      :response => response,
      :request => req,
    }
  end

  def default_payment_method_params
    @default_payment_method_params ||= {
      'redirect_url' => 'http://test.host',
      'merchant_key' => Samurai.merchant_key,
      'custom' => 'custom',
      'credit_card[first_name]' => 'FirstName',
      'credit_card[last_name]' => 'LastName',
      'credit_card[address_1]' => '1000 1st Av',
      'credit_card[address_2]' => '',
      'credit_card[city]' => 'Chicago',
      'credit_card[state]' => 'IL',
      'credit_card[zip]' => '10101',
      'credit_card[card_number]' => '4111111111111111',
      'credit_card[cvv]' => '111',
      'credit_card[expiry_month]' => '05',
      'credit_card[expiry_year]' => '2014',
    }
  end

end
