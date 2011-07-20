require 'test/spec_helper'

describe "fetch a transaction" do
  
  it "should return a valid authorization transaction" do
    # set up 
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, 15.00)
    
    register_transaction_response(:method => :get, :path => "transactions/#{authorization.id}", :type => 'authorize')
    transaction = Samurai::Transaction.find(authorization.reference_id)
    transaction.should_not be_new_record
  end
  
end

describe "void an authorization" do
  
  it "should return a non-new void transaction" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, 15.00)

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/void", :type => 'void')
    
    void = authorization.void
    void.should_not be_new_record
  end
  
end

describe "credit an authorization" do
  
  it "should return a non-new model" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, 15.00)
    
    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/credit", :type => 'credit')
    credit = authorization.credit(10.0)
    credit.should_not be_new_record
  end
  
end
