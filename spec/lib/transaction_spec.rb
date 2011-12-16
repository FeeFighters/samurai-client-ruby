require 'spec_helper'

describe "Transaction" do
  before do
    @rand = rand(1000)
    @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
  end

  describe 'capture' do
    describe 'success' do
      before do
        @auth = Samurai::Processor.authorize(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        capture = @auth.capture
        capture.success.should be_true
      end
      it 'should be successful for full amount' do
        capture = @auth.capture(100.0)
        capture.success.should be_true
      end
      it 'should be successful for partial amount' do
        capture = @auth.capture(50.0)
        capture.success.should be_true
      end
    end
    describe 'failures' do
      it 'should return processor.transaction - invalid with declined auth' do
        auth = Samurai::Processor.authorize(@payment_method_token, 100.02)  # declined auth
        capture = auth.capture
        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'This transaction type is not allowed.' ]
      end
      it 'should return processor.transaction - declined' do
        auth = Samurai::Processor.authorize(@payment_method_token, 100.00)
        capture = auth.capture(100.02)
        capture.success.should be_false
        capture.errors['processor.transaction'].should == [ 'The card was declined.' ]
      end
      it 'should return input.amount - invalid' do
        auth = Samurai::Processor.authorize(@payment_method_token, 100.00)
        capture = auth.capture(100.10)
        capture.success.should be_false
        capture.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'reverse' do
    describe 'on capture' do
      before do
        @purchase = Samurai::Processor.purchase(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        reverse = @purchase.reverse
        reverse.success.should be_true
      end
      it 'should be successful for full amount' do
        reverse = @purchase.reverse(100.0)
        reverse.success.should be_true
      end
      it 'should be successful for partial amount' do
        reverse = @purchase.reverse(50.0)
        reverse.success.should be_true
      end
    end
    describe 'on authorize' do
      before do
        @authorize = Samurai::Processor.authorize(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        reverse = @authorize.reverse
        reverse.success.should be_true
      end
    end
    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = Samurai::Processor.purchase(@payment_method_token, 100.00)
        reverse = purchase.reverse(100.10)
        reverse.success.should be_false
        reverse.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'credit' do
    describe 'on capture' do
      before do
        @purchase = Samurai::Processor.purchase(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        credit = @purchase.credit
        credit.success.should be_true
      end
      it 'should be successful for full amount' do
        credit = @purchase.credit(100.0)
        credit.success.should be_true
      end
      it 'should be successful for partial amount' do
        credit = @purchase.credit(50.0)
        credit.success.should be_true
      end
    end
    describe 'on authorize' do
      before do
        @authorize = Samurai::Processor.authorize(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        credit = @authorize.credit
        credit.success.should be_true
      end
    end
    describe 'failures' do
      it 'should return input.amount - invalid' do
        purchase = Samurai::Processor.purchase(@payment_method_token, 100.00)
        credit = purchase.credit(100.10)
        credit.success.should be_false
        credit.errors['input.amount'].should == [ 'The transaction amount was invalid.' ]
      end
    end
  end

  describe 'void' do
    describe 'on authorized' do
      before do
        @authorize = Samurai::Processor.authorize(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        void = @authorize.void
        void.success.should be_true
      end
    end
    describe 'on captured' do
      before do
        @purchase = Samurai::Processor.purchase(@payment_method_token, 100.0)
      end
      it 'should be successful' do
        void = @purchase.void
        void.success.should be_true
      end
    end
  end

  #before :each do
  #  payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
  #  @authorization = Samurai::Processor.authorize(payment_method_token, 1.0, :billing_reference=>rand(1000))
  #end
  #
  #it "should create a new authorization transaction" do
  #  @authorization.processor_response.success.should be_true
  #end
  #
  #it "should find the authorization" do
  #  transaction = Samurai::Transaction.find(@authorization.reference_id)
  #  transaction.reference_id.should == @authorization.reference_id
  #end
  #
  #it "should successfully capture" do
  #  capture = @authorization.capture(1.0)
  #  capture.processor_response.success.should be_true
  #end
  #
  #it "should capture an authorization without specifying an amount" do
  #  capture = @authorization.capture
  #  capture.amount.should == "#{1.0}"
  #  capture.processor_response.success.should be_true
  #end
  #
  #it "should partially capture an authorization" do
  #  capture = @authorization.capture(BigDecimal('0.5'))
  #  capture.amount.should == "#{BigDecimal('0.5')}"
  #  capture.processor_response.success.should be_true
  #end
  #
  #it "should void an authorization" do
  #  void = @authorization.void
  #  void.processor_response.success.should be_true
  #end
  #
  #it "should credit an authorization for the full amount by default" do
  #  credit = @authorization.credit
  #  credit.amount.should == "#{BigDecimal('1.0')}"
  #  credit.processor_response.success.should be_true
  #end
  #
  #it "should partially credit an authorization" do
  #  credit = @authorization.credit(BigDecimal('0.5'))
  #  credit.amount.should == "#{BigDecimal('0.5')}"
  #  credit.processor_response.success.should be_true
  #end
end
