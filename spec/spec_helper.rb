require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 5
Debugger.settings[:reload_source_on_change] = true

SITE = ENV['site'] || 'http://localhost:3002/v1/'
USE_MOCK = !ENV['site']
PAYMENT_METHOD_TOKEN = ENV['payment_method_token'] || 'asdf'

RSpec.configure do |c|
  c.before :all do
    @@seed = rand(1000).to_f / 100.0
  end
  c.before :each do
    @@seed += 1.0
  end
end

require 'fakeweb'
FakeWeb.allow_net_connect = !USE_MOCK

require 'samurai'
Samurai.options = {
  :site => SITE, 
  :merchant_key => ENV['merchant_key'] || 'e62c5a006cdd9908234193bc',
  :merchant_password => ENV['merchant_password'] || '18e87d97b3a44b56fe07497e4812f14555db69df9e6ca16f', 
  :processor_token => ENV['processor_token'] || 'af762c3499f77c5f181650a7'
}

def register_transaction_response(options)
  return unless USE_MOCK
  
  options.symbolize_keys!

  method = options[:method] && options[:method].to_sym || :post
  type = options[:type]
  path = options[:path] || "processors/af762c3499f77c5f181650a7/#{type}"
  payment_method_token = options[:payment_method_token] || PAYMENT_METHOD_TOKEN
  amount = options[:amount] || 15.00
  success = options[:success].blank? ? true : options[:success]
  
  FakeWeb.register_uri(method, 
    "http://e62c5a006cdd9908234193bc:18e87d97b3a44b56fe07497e4812f14555db69df9e6ca16f@localhost:3002/v1/#{path}.xml", 
    :body => <<-EOF
    <transaction>
    <reference_id>3dcFjTC7LDjIjTY3nkKjBVZ8qkZ</reference_id>
    <transaction_token>53VFyQKYBmN9vKfA9mHCTs79L9a</transaction_token>
    <created_at type="datetime">2011-04-22T17:57:56Z</created_at>
    <descriptor>Custom descriptor here if your processor supports it.</descriptor>
    <custom>Any value you like.</custom>
    <transaction_type>#{type}</transaction_type>
    <amount>#{amount}</amount>
    <currency_code>USD</currency_code>
    <processor_token>af762c3499f77c5f181650a7</processor_token>
    <processor_response>
      <success type="boolean">#{success}</success>
      <messages type="array">
        <message class="error" context="processor.avs" key="country_not_supported" />
        <message class="error" context="input.cvv" key="too_short" />
      </messages>
    </processor_response>
    <payment_method>
      <payment_method_token>#{payment_method_token}</payment_method_token>
        <created_at type="datetime">2011-02-12T20:20:46Z</created_at>
        <updated_at type="datetime">2011-04-22T17:57:30Z</updated_at>
        <custom>Any value you want us to save with this payment method.</custom>
        <is_retained type="boolean">true</is_retained>
        <is_redacted type="boolean">false</is_redacted>
        <is_sensitive_data_valid type="boolean">true</is_sensitive_data_valid>
        <messages type="array">
          <message class="error" context="input.cvv" key="too_long" />
          <message class="error" context="input.card_number" key="failed_checksum" />
        </messages>
        <last_four_digits>1111</last_four_digits>
        <card_type>visa</card_type>
        <first_name>Bob</first_name>
        <last_name>Smith</last_name>
        <expiry_month type="integer">1</expiry_month>
        <expiry_year type="integer">2020</expiry_year>
        <address_1 nil="true"></address_1>
        <address_2 nil="true"></address_2>
        <city nil="true"></city>
        <state nil="true"></state>
        <zip nil="true"></zip>
        <country nil="true"></country>
    </payment_method>
  </transaction>
  EOF
  )
end
