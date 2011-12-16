require 'spec_helper'

describe "Processor" do
  before :each do
    @rand = rand(1000)
    @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
  end

  describe 'the_processor' do
    it "should return the default processor" do
      processor = Samurai::Processor.the_processor
      processor.should_not be_nil
      processor.token.should == DEFAULT_OPTIONS[:processor_token]
    end
  end

  describe 'new processor' do
    it "should return a processor" do
      processor = Samurai::Processor.new(:id=>'abc123')
      processor.should_not be_nil
      processor.token.should == 'abc123'
    end
  end

  describe 'purchase' do
    it 'should be successful' do
      purchase = Samurai::Processor.purchase(@payment_method_token, 100.0, {
        :descriptor => "descriptor",
        :custom => "custom_data",
        :billing_reference => "ABC123#{@rand}",
        :customer_reference => "Customer (123)",
      })
      purchase.success.should be_true
      purchase.descriptor.should == 'descriptor'
      purchase.custom.should == 'custom_data'
      purchase.billing_reference.should == "ABC123#{@rand}"
      purchase.customer_reference.should == "Customer (123)"
    end
    describe 'failures' do
      it 'should return processor.transaction - declined' do
        purchase = Samurai::Processor.purchase(@payment_method_token, 1.02, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end
      it 'should return input.amount - invalid' do
        purchase = Samurai::Processor.purchase(@payment_method_token, 1.10, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
      it 'should return input.card_number - failed_checksum (invalid payment method)' #do
      #  params = default_payment_method_params.merge('credit_card[card_number]'=>'1234123412341234')
      #  @payment_method_token = create_payment_method(params)[:payment_method_token]
      #  purchase = Samurai::Processor.purchase(@payment_method_token, 1.00, :billing_reference=>rand(1000))
      #  purchase.success.should be_false
      #  purchase.errors['input.card_number'].should == [ 'The card number was invalid.' ]
      #end
      it 'should return input.card_number - invalid (invalid payment method)' #do
      #  params = default_payment_method_params.merge('credit_card[card_number]'=>'5105105105105100')
      #  @payment_method_token = create_payment_method(params)[:payment_method_token]
      #  purchase = Samurai::Processor.purchase(@payment_method_token, 1.00, :billing_reference=>rand(1000))
      #  purchase.success.should be_false
      #  purchase.errors['input.card_number'].should == [ 'The card number was invalid.' ]
      #end
    end
    describe 'cvv responses' do
      it 'should return processor.cvv_result_code = M' do
        params = default_payment_method_params.merge('credit_card[cvv]'=>'111')
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.cvv_result_code.should == 'M'
      end
      it 'should return processor.cvv_result_code = N' do
        params = default_payment_method_params.merge('credit_card[cvv]'=>'222')
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.cvv_result_code.should == 'N'
      end
    end
    describe 'avs responses' do
      it 'should return processor.avs_result_code = Y' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '1000 1st Av',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '10101',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'Y'
      end
      it 'should return processor.avs_result_code = Z' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '10101',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'Z'
      end
      it 'should return processor.avs_result_code = N' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '123 Main St',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '60610',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        Samurai::PaymentMethod.find(payment_method_token)
        purchase = Samurai::Processor.purchase(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'N'
      end
    end
  end

  describe 'authorize' do
    it 'should be successful' do
      purchase = Samurai::Processor.authorize(@payment_method_token, 100.0, {
        :descriptor => "descriptor",
        :custom => "custom_data",
        :billing_reference => "ABC123#{@rand}",
        :customer_reference => "Customer (123)",
      })
      purchase.success.should be_true
      purchase.descriptor.should == 'descriptor'
      purchase.custom.should == 'custom_data'
      purchase.billing_reference.should == "ABC123#{@rand}"
      purchase.customer_reference.should == "Customer (123)"
    end
    describe 'failures' do
      it 'should return processor.transaction - declined' do
        purchase = Samurai::Processor.authorize(@payment_method_token, 1.02, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end
      it 'should return input.amount - invalid' do
        purchase = Samurai::Processor.authorize(@payment_method_token, 1.10, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
      it 'should return input.card_number - is_invalid (invalid payment method)' do
        params = default_payment_method_params.merge('credit_card[card_number]'=>'1234123412341234')
        @payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.authorize(@payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_false
        purchase.errors['input.card_number'].should == [ 'The card number was invalid.' ]
      end
    end
    describe 'cvv responses' do
      it 'should return processor.cvv_result_code = M' do
        params = default_payment_method_params.merge('credit_card[cvv]'=>'111')
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.cvv_result_code.should == 'M'
      end
      it 'should return processor.cvv_result_code = N' do
        params = default_payment_method_params.merge('credit_card[cvv]'=>'222')
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.cvv_result_code.should == 'N'
      end
    end
    describe 'avs responses' do
      it 'should return processor.avs_result_code = Y' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '1000 1st Av',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '10101',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'Y'
      end
      it 'should return processor.avs_result_code = Z' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '10101',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        purchase = Samurai::Processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'Z'
      end
      it 'should return processor.avs_result_code = N' do
        params = default_payment_method_params.merge({
          'credit_card[address_1]'  => '123 Main St',
          'credit_card[address_2]'  => '',
          'credit_card[zip]'        => '60610',
        })
        payment_method_token = create_payment_method(params)[:payment_method_token]
        Samurai::PaymentMethod.find(payment_method_token)
        purchase = Samurai::Processor.authorize(payment_method_token, 1.00, :billing_reference=>rand(1000))
        purchase.success.should be_true
        purchase.processor_response.avs_result_code.should == 'N'
      end
    end
  end


end
