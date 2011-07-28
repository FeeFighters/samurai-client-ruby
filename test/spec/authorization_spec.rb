require 'test/spec_helper'

describe "processing authorizations" do
  
  before :each do
    register_transaction_response(:type => 'authorize')
    @authorization = Samurai::Processor.authorize(PAYMENT_METHOD_TOKEN, @@seed)
  end
  
  it "should create a new authorization transaction" do
    @authorization.processor_response.success.should be_true
  end

  it "should find the authorization" do
    register_transaction_response(:method => :get, :path => "transactions/#{@authorization.reference_id}", :type => 'authorize')
    transaction = Samurai::Transaction.find(@authorization.reference_id)
    transaction.reference_id.intern.should be_equal(@authorization.reference_id.intern)
  end

  it "should successfully capture" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/capture", :type => 'capture')
    capture = @authorization.capture(@@seed)
    capture.processor_response.success.should be_true
  end
  
  it "should capture an authorization without specifying an amount" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/capture", :type => 'capture', :amount => @@seed)
    capture = @authorization.capture
    capture.amount.intern.should be_equal "#{@@seed}".intern
    capture.processor_response.success.should be_true
  end

  it "should partially capture an authorization" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/capture", :type => 'capture', :amount => @@seed - 1.0)
    capture = @authorization.capture(@@seed - 1.0)
    capture.amount.intern.should be_equal "#{@@seed - 1.0}".intern
    capture.processor_response.success.should be_true
  end

  it "should void an authorization" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/void", :type => 'void', :amount => @@seed)
    void = @authorization.void
    void.processor_response.success.should be_true
  end

  it "should credit an authorization for the full amount by default" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/credit", :type => 'credit', :amount => @@seed, :success => 'false')
    credit = @authorization.credit
    credit.amount.intern.should be_equal "#{@@seed}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end

  it "should partially credit an authorization" do
    register_transaction_response(:method => :post, :path => "transactions/#{@authorization.id}/credit", :type => 'credit', :amount => @@seed - 1.0, :success => 'false')
    credit = @authorization.credit(@@seed - 1.0)
    credit.amount.intern.should be_equal "#{@@seed - 1.0}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end
end
