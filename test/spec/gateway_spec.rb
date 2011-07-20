require 'test/spec_helper'

describe "Gateway actions" do
  
  it "should return an empty gateway" do
    gateway = Samurai::Gateway.the_gateway
    gateway.should_not be_nil
  end
  
  it "should create a new purchase" do
    register_transaction_response(:type => 'purchase')
    
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, 25.00)
    purchase.should_not be_new_record
    # FakeWeb.last_request
  end
    
  it "should create a non-new authorization" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, 15.00)
    authorization.should_not be_nil
    authorization.should_not be_new_record
  end
  
end
