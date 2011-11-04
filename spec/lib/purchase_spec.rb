require 'spec_helper'

describe "processing purchases" do

  before :each do
    payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
    @purchase = Samurai::Processor.purchase(payment_method_token, 1.0, :billing_reference=>rand(1000))
  end
  
  it "should process successfully" do
    @purchase.processor_response.success.should be_true
  end

  it "should be able to void a recent purchase" do
    void = @purchase.void
    void.processor_response.success.should be_true
  end

  it "should not be able to credit a recent purchase" do
    credit = @purchase.credit
    credit.processor_response.success.should be_false
  end

  it "should be able to reverse a recent purchase" do
    reverse = @purchase.reverse
    reverse.processor_response.success.should be_true
  end

  it "should be able to reverse a settled purchase" do
    pending "currently we cannot force settle a purchase, so can't test this properly"
    reverse = @purchase.reverse
    reverse.processor_response.success.should be_true
  end

  it "should be able to credit a settled purchase" do
    pending "currently we cannot force settle a purchase, so can't test this properly"
    credit = @purchase.credit
    credit.processor_response.success.should be_true
  end
end
