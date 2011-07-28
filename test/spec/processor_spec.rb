require 'test/spec_helper'

describe "Processor actions" do
  
  it "should return an empty processor" do
    processor = Samurai::Processor.the_processor
    processor.should_not be_nil
  end
  
  it "should create a new purchase" do
    register_transaction_response(:type => 'purchase')
    
    purchase = Samurai::Processor.purchase(PAYMENT_METHOD_TOKEN, @@seed)
    purchase.processor_response.success.should be_true
    # FakeWeb.last_request
  end

  it "should create a new purchase with tracking data" do
    register_transaction_response(:type => 'purchase')
    
    purchase = Samurai::Processor.purchase(PAYMENT_METHOD_TOKEN, @@seed, {
      :descriptor => "A test purchase", 
      :custom => "some optional custom data",
      :billing_reference => "ABC123",
      :customer_reference => "Customer (123)"
    })
    purchase.processor_response.success.should be_true
    # FakeWeb.last_request
  end
    
  it "should create a non-new authorization" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Processor.authorize(PAYMENT_METHOD_TOKEN, @@seed)
    authorization.processor_response.success.should be_true
  end
  
end
