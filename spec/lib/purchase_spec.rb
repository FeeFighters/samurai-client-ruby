require 'spec_helper'

describe "processing purchases" do

  before :each do
    payment_method_token = PAYMENT_METHOD_TOKENS[:success]
    @purchase = Samurai::Processor.purchase(payment_method_token, @@seed)
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

  it "should be able to credit a settled purchase" do
    pending "currently we cannot force settle a purchase, so can't test this properly" do
      credit = @purchase.credit
      credit.processor_response.success.should be_true
    end
  end
end
