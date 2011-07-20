require 'test/spec_helper'

describe "Gateway actions" do
  
  it "should return an empty gateway" do
    gateway = Samurai::Gateway.the_gateway
    gateway.should_not be_nil
  end
  
  it "should create a new purchase" do
    register_transaction_response(:type => 'purchase')
    
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, @@seed)
    purchase.gateway_response.success.should be_true
    # FakeWeb.last_request
  end

  it "should create a new purchase with tracking data" do
    register_transaction_response(:type => 'purchase')
    
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, @@seed, {
      :descriptor => "A test purchase", 
      :custom => "some optional custom data",
      :billing_reference => "ABC123",
      :customer_reference => "Customer (123)"
    })
    purchase.gateway_response.success.should be_true
    # FakeWeb.last_request
  end
    
  it "should create a non-new authorization" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, @@seed)
    authorization.gateway_response.success.should be_true
  end
  
end
