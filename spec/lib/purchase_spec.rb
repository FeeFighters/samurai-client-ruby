require 'spec_helper'

describe "processing purchases" do

  describe 'for a successful transaction' do
    before :each do
      @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
      @purchase = Samurai::Processor.purchase(@payment_method_token, 1.0, :billing_reference=>rand(1000))
    end

    it "should process successfully" do
      @purchase.processor_response.success.should be_true
    end

    it "should be able to void a recent purchase" do
      void = @purchase.void
      void.processor_response.success.should be_true
    end

    it "should be able to credit a recent purchase" do
      credit = @purchase.credit
      credit.processor_response.success.should be_true
      credit.transaction_type.should == 'Credit'
    end

    it "should be able to reverse a recent purchase" do
      reverse = @purchase.reverse
      reverse.processor_response.success.should be_true
      reverse.transaction_type.should == 'Credit'
    end

    it "should be able to reverse a settled purchase" do
      reverse = @purchase.reverse
      reverse.processor_response.success.should be_true
    end

    it "should be able to credit a settled purchase" do
      credit = @purchase.credit
      credit.processor_response.success.should be_true
    end
  end

  describe 'for a declined transaction' do
    before :each do
      @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
      @purchase = Samurai::Processor.purchase(@payment_method_token, 1.02)
    end

    it "should process" do
      @purchase.processor_response.success.should be_false
      [@purchase.errors['processor.transaction']].flatten.first.should == 'The card was declined.'
    end
  end


  describe 'for a invalid card number transaction' do
    before :each do
      @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
      @purchase = Samurai::Processor.purchase(@payment_method_token, 1.07)
    end

    it "should process" do
      @purchase.processor_response.success.should be_false
      [@purchase.errors['input.card_number']].flatten.first.should == 'The card number was invalid.'
    end
  end

  describe 'for a expired card transaction' do
    before :each do
      @payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
      @purchase = Samurai::Processor.purchase(@payment_method_token, 1.08)
    end

    it "should process" do
      @purchase.processor_response.success.should be_false
      [@purchase.errors['input.expiry_month']].flatten.first.should == 'The expiration date month was invalid, or prior to today.'
      [@purchase.errors['input.expiry_year']].flatten.first.should == 'The expiration date year was invalid, or prior to today.'
    end
  end


end
