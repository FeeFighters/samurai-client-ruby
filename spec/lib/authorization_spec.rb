require 'spec_helper'

describe "processing authorizations" do
  
  before :each do
    payment_method_token = create_payment_method(default_payment_method_params)[:payment_method_token]
    @authorization = Samurai::Processor.authorize(payment_method_token, 1.0, :billing_reference=>rand(1000))
  end
  
  it "should create a new authorization transaction" do
    @authorization.processor_response.success.should be_true
  end

  it "should find the authorization" do
    transaction = Samurai::Transaction.find(@authorization.reference_id)
    transaction.reference_id.intern.should be_equal(@authorization.reference_id.intern)
  end

  it "should successfully capture" do
    capture = @authorization.capture(1.0)
    capture.processor_response.success.should be_true
  end
  
  it "should capture an authorization without specifying an amount" do
    capture = @authorization.capture
    capture.amount.intern.should be_equal "#{1.0}".intern
    capture.processor_response.success.should be_true
  end

  it "should partially capture an authorization" do
    capture = @authorization.capture(1.0 - BigDecimal('0.5'))
    capture.amount.intern.should be_equal "#{1.0 - BigDecimal('0.5')}".intern
    capture.processor_response.success.should be_true
  end

  it "should void an authorization" do
    void = @authorization.void
    void.processor_response.success.should be_true
  end

  it "should credit an authorization for the full amount by default" do
    credit = @authorization.credit
    credit.amount.intern.should be_equal "#{1.0}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end

  it "should partially credit an authorization" do
    credit = @authorization.credit(1.0 - BigDecimal('0.5'))
    credit.amount.intern.should be_equal "#{1.0 - BigDecimal('0.5')}".intern
    pending "the response is not successful since the authorization hasn't settled" do
      credit.processor_response.success.should be_true
    end
  end
end
