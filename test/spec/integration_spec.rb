require 'test/spec_helper'

describe "process a purchase" do

  it "should process successfully" do
    register_transaction_response(:type => 'purchase')
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(1.00))
    purchase.should_not be_new_record
    purchase.gateway_response.success.should be_true
  end
  
end

describe "void a purchase" do
  
  it "should create a void transaction" do
    pending "currently we cannot void a purchase" do
      register_transaction_response(:type => 'purchase')
      purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(2.00))
    
      register_transaction_response(:method => :post, :path => "transactions/#{purchase.id}/void", :type => 'void', :success => 'false')
      void = purchase.void
      void.should_not be_new_record
      void.gateway_response.success.should be_true
    end
  end
  
end

describe "credit a purchase" do
  
  it "should create create a credit transaction" do
    pending "currently we cannot credit a purchase" do
      register_transaction_response(:type => 'purchase')
      purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(3.00))
    
      register_transaction_response(:method => :post, :path => "transactions/#{purchase.id}/credit", :type => 'void', :success => 'false')
      credit = purchase.credit
      credit.gateway_response.success.should be_true
    end
  end
  
end

describe "process an authorization" do
  it "should create a new authorization transaction" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(1.00))
    authorization.gateway_response.success.should be_true
  end
end

describe "capture an authorization" do
  it "should successfully capture" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(2.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture')
    capture = authorization.capture(seed_amount(2.0))
    capture.gateway_response.success.should be_true
  end
  
  it "should create a capture transaction without an amount" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(3.00))
    
    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture', :amount => seed_amount(3.0))
    capture = authorization.capture
    capture.amount.intern.should be_equal "#{seed_amount(3.00)}".intern
    capture.gateway_response.success.should be_true
  end

  it "should create a partial capture transaction" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(4.00))
    
    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture', :amount => seed_amount(3.0))
    capture = authorization.capture(seed_amount(3.00))
    capture.amount.intern.should be_equal "#{seed_amount(3.00)}".intern
    capture.gateway_response.success.should be_true
  end
end

describe "void an authorization" do
  it "should create a successful void transaction" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(5.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/void", :type => 'void', :amount => seed_amount(5.0))
    void = authorization.void
    void.gateway_response.success.should be_true
  end
end

describe "credit an authorization" do
  it "should create a successful credit for the full amount" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(6.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/credit", :type => 'credit', :amount => seed_amount(6.0), :success => 'false')
    credit = authorization.credit
    credit.amount.intern.should be_equal "#{seed_amount(6.00)}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.gateway_response.success.should be_true
    end
  end

  it "should create a successful credit for the partial amount" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(7.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/credit", :type => 'credit', :amount => seed_amount(2.0), :success => 'false')
    credit = authorization.credit(seed_amount(2.0))
    credit.amount.intern.should be_equal "#{seed_amount(2.00)}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.gateway_response.success.should be_true
    end
  end
end
