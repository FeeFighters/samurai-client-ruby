require 'spec_helper'

describe "processing authorizations" do
  
  before :each do
    payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
    @authorization = Samurai::Processor.authorize(payment_method_token, @seed)
  end
  
  it "should create a new authorization transaction" do
    @authorization.processor_response.success.should be_true
  end

  it "should find the authorization" do
    transaction = Samurai::Transaction.find(@authorization.reference_id)
    transaction.reference_id.intern.should be_equal(@authorization.reference_id.intern)
  end

  it "should successfully capture" do
    capture = @authorization.capture(@seed)
    capture.processor_response.success.should be_true
  end
  
  it "should capture an authorization without specifying an amount" do
    capture = @authorization.capture
    capture.amount.intern.should be_equal "#{@seed}".intern
    capture.processor_response.success.should be_true
  end

  it "should partially capture an authorization" do
    capture = @authorization.capture(@seed - BigDecimal('1.0'))
    capture.amount.intern.should be_equal "#{@seed - BigDecimal('1.0')}".intern
    capture.processor_response.success.should be_true
  end

  it "should void an authorization" do
    void = @authorization.void
    void.processor_response.success.should be_true
  end

  it "should credit an authorization for the full amount by default" do
    credit = @authorization.credit
    credit.amount.intern.should be_equal "#{@seed}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end

  it "should partially credit an authorization" do
    credit = @authorization.credit(@seed - BigDecimal('1.0'))
    credit.amount.intern.should be_equal "#{@seed - BigDecimal('1.0')}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end
end
