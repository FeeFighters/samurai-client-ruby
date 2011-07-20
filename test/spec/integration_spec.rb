require 'test/spec_helper'

describe "processing purchases" do
  it "should process successfully" do
    register_transaction_response(:type => 'purchase')
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(1.00))
    purchase.should_not be_new_record
    purchase.gateway_response.success.should be_true
  end

  it "should be able to void a recent purchase" do
    register_transaction_response(:type => 'purchase')
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(2.00))
  
    register_transaction_response(:method => :post, :path => "transactions/#{purchase.id}/void", :type => 'void', :success => 'false')
    void = purchase.void
    void.should_not be_new_record
    void.gateway_response.success.should be_true
  end

  it "should not be able to credit a recent purchase" do
    register_transaction_response(:type => 'purchase')
    purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(3.00))
  
    register_transaction_response(:method => :post, :path => "transactions/#{purchase.id}/credit", :type => 'void', :success => 'false')
    credit = purchase.credit
    credit.gateway_response.success.should be_false
  end

  it "should be able to credit a settled purchase" do
    pending "currently we cannot force settle a purchase, so can't test this properly" do
      register_transaction_response(:type => 'purchase')
      purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, seed_amount(3.00))
    
      register_transaction_response(:method => :post, :path => "transactions/#{purchase.id}/credit", :type => 'void', :success => 'false')
      credit = purchase.credit
      credit.gateway_response.success.should be_true
    end
  end
end

describe "processing authorizations" do
  it "should create a new authorization transaction" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(1.00))
    authorization.gateway_response.success.should be_true
  end

  it "should successfully capture" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(2.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture')
    capture = authorization.capture(seed_amount(2.0))
    capture.gateway_response.success.should be_true
  end
  
  it "should capture an authorization without specifying an amount" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(3.00))
    
    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture', :amount => seed_amount(3.0))
    capture = authorization.capture
    capture.amount.intern.should be_equal "#{seed_amount(3.00)}".intern
    capture.gateway_response.success.should be_true
  end

  it "should partially capture an authorization" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(4.00))
    
    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/capture", :type => 'capture', :amount => seed_amount(3.0))
    capture = authorization.capture(seed_amount(3.00))
    capture.amount.intern.should be_equal "#{seed_amount(3.00)}".intern
    capture.gateway_response.success.should be_true
  end

  it "should void an authorization" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(5.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/void", :type => 'void', :amount => seed_amount(5.0))
    void = authorization.void
    void.gateway_response.success.should be_true
  end

  it "should credit an authorization for the full amount by default" do
    register_transaction_response(:type => 'authorize')
    authorization = Samurai::Gateway.authorize(PAYMENT_METHOD_TOKEN, seed_amount(6.00))

    register_transaction_response(:method => :post, :path => "transactions/#{authorization.id}/credit", :type => 'credit', :amount => seed_amount(6.0), :success => 'false')
    credit = authorization.credit
    credit.amount.intern.should be_equal "#{seed_amount(6.00)}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.gateway_response.success.should be_true
    end
  end

  it "should partially credit an authorization" do
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
