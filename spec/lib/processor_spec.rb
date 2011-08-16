require 'spec_helper'

describe "Processor actions" do
  before :each do
    @payment_method_token = PAYMENT_METHOD_TOKENS[:success]
  end

  it "should return an empty processor" do
    processor = Samurai::Processor.the_processor
    processor.should_not be_nil
  end
  
  it "should create a new purchase" do
    purchase = Samurai::Processor.purchase(@payment_method_token, @@seed)
    purchase.processor_response.success.should be_true
    # FakeWeb.last_request
  end

  it "should create a new purchase with tracking data" do
    purchase = Samurai::Processor.purchase(@payment_method_token, @@seed, {
      :descriptor => "A test purchase", 
      :custom => "some optional custom data",
      :billing_reference => "ABC123",
      :customer_reference => "Customer (123)"
    })
    purchase.processor_response.success.should be_true
    # FakeWeb.last_request
  end
    
  it "should create a non-new authorization" do
    authorization = Samurai::Processor.authorize(@payment_method_token, @@seed)
    authorization.processor_response.success.should be_true
  end
  
end
