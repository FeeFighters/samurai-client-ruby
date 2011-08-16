require 'spec_helper'

describe "generate documentation" do
  include TransparentRedirectHelper
  include ResponseLoggerHelper

  before(:all) do
    @logger = ResponseLogger.new(File.open('response_log.html', 'w'))
  end
  after(:all) do
    @logger.close!
  end

  before do
    @params = {
      'redirect_url' => 'http://test.host',
      'merchant_key' => Samurai.merchant_key,
      'custom' => 'custom',
      'credit_card[first_name]' => 'FirstName',
      'credit_card[last_name]' => 'LastName',
      'credit_card[address_1]' => '123 Main St',
      'credit_card[address_2]' => '',
      'credit_card[city]' => 'Chicago',
      'credit_card[state]' => 'IL',
      'credit_card[zip]' => '60610',
      'credit_card[card_number]' => '4222222222222',
      'credit_card[cvv]' => '123',
      'credit_card[expiry_month]' => '05',
      'credit_card[expiry_year]' => '2014',
    }

    Samurai::Base.instance_eval do
      def connection(refresh = false)
        if defined?(@connection) || superclass == ActiveResource::Base
          @connection ||= begin
            c = HttpProxyConnection.new(site, format)
            c.proxy = proxy if proxy
            c.user = user if user
            c.password = password if password
            c.auth_type = auth_type if auth_type
            c.timeout = timeout if timeout
            c.ssl_options = ssl_options if ssl_options
            c
          end
        else
          superclass.connection
        end
      end
    end
    Samurai::Base.connection
  end

  describe 'with an invalid payment method' do
    it 'should not create the payment method' do
      @params.delete 'credit_card[card_number]'
      data = create_payment_method(@params)
      log_request_response! data[:request], data[:response]
      data[:payment_method_token].should be_nil
    end
  end

  describe 'with a valid payment method' do
    before do
      @amount = '1.00' # response code: card number is declined
      @data = create_payment_method(@params)
    end
    it 'should create the payment method' do
      log_request_response! @data[:request], @data[:response]
      @data[:payment_method_token].should =~ /^[0-9a-z]{24}$/
    end
    it 'should create a valid transaction' do
      purchase = Samurai::Processor.purchase(@data[:payment_method_token], @amount)
      log_http!
      purchase.processor_response.success.should be_true
    end    
    it 'should create an invalid transaction' do
      lambda do
        Samurai::Processor.purchase(@data[:payment_method_token], '')
      end.should raise_error(ActiveResource::ServerError)
      log_http!
    end
  end

  describe 'with a declined card' do
    before do
      @amount = '3.00' # response code: card number is declined
      @data = create_payment_method(@params)
    end
    it 'should create the payment method' do
      log_request_response! @data[:request], @data[:response]
      @data[:payment_method_token].should =~ /^[0-9a-z]{24}$/
    end
    it 'should create a valid transaction' do
      purchase = Samurai::Processor.purchase(@data[:payment_method_token], @amount)
      log_http!
      purchase.processor_response.success.should be_false
    end
    it 'should create an invalid transaction' do
      lambda do
        Samurai::Processor.purchase(@data[:payment_method_token], '')
      end.should raise_error(ActiveResource::ServerError)
      log_http!
    end
  end

  describe 'with an expired card' do
    before do
      @amount = '8.00' # response code: card is expired
      @data = create_payment_method(@params)
    end
    it 'should create the payment method' do
      log_request_response! @data[:request], @data[:response]
      @data[:payment_method_token].should =~ /^[0-9a-z]{24}$/
    end
    it 'should create a valid transaction' do
      purchase = Samurai::Processor.purchase(@data[:payment_method_token], @amount)
      log_http!
      purchase.processor_response.success.should be_false
    end
    it 'should create an invalid transaction' do
      lambda do
        Samurai::Processor.purchase(@data[:payment_method_token], '')
      end.should raise_error(ActiveResource::ServerError)
      log_http!
    end
  end

  describe 'with a card with incorrect cvv' do
    before do
      @amount = '6.00' # response code: card number is invalid
      @data = create_payment_method(@params)
    end
    it 'should create the payment method' do
      log_request_response! @data[:request], @data[:response]
      @data[:payment_method_token].should =~ /^[0-9a-z]{24}$/
    end
    it 'should create a valid transaction' do
      purchase = Samurai::Processor.purchase(@data[:payment_method_token], @amount)
      log_http!
      purchase.processor_response.success.should be_false
    end
    it 'should create an invalid transaction' do
      lambda do
        Samurai::Processor.purchase(@data[:payment_method_token], '')
      end.should raise_error(ActiveResource::ServerError)
      log_http!
    end
  end

  describe 'with an nonexistant card' do
    before do
      @params['credit_card[card_number]'] = '4222222222222'
      @amount = '6.00' # response code: card number is invalid
      @data = create_payment_method(@params)
    end
    it 'should create the payment method' do
      log_request_response! @data[:request], @data[:response]
      @data[:payment_method_token].should =~ /^[0-9a-z]{24}$/
    end
    it 'should create a valid transaction' do
      purchase = Samurai::Processor.purchase(@data[:payment_method_token], @amount)
      log_http!
      purchase.processor_response.success.should be_false
    end
    it 'should create an invalid transaction' do
      lambda do
        Samurai::Processor.purchase(@data[:payment_method_token], '')
      end.should raise_error(ActiveResource::ServerError)
      log_http!
    end
  end

end
