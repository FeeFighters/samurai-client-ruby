require 'test/spec_helper'

describe "processing purchases" do

  before :each do
    register_transaction_response(:type => 'purchase')
    @purchase = Samurai::Gateway.purchase(PAYMENT_METHOD_TOKEN, @@seed)
  end
  
  it "should process successfully" do
    @purchase.gateway_response.success.should be_true
  end

  it "should be able to void a recent purchase" do
    register_transaction_response(:method => :post, :path => "transactions/#{@purchase.id}/void", :type => 'void', :success => 'false')
    void = @purchase.void
    void.gateway_response.success.should be_true
  end

  it "should not be able to credit a recent purchase" do
    register_transaction_response(:method => :post, :path => "transactions/#{@purchase.id}/credit", :type => 'void', :success => 'false')
    credit = @purchase.credit
    credit.gateway_response.success.should be_false
  end

  it "should be able to credit a settled purchase" do
    pending "currently we cannot force settle a purchase, so can't test this properly" do
      register_transaction_response(:method => :post, :path => "transactions/#{@purchase.id}/credit", :type => 'void', :success => 'false')
      credit = @purchase.credit
      credit.gateway_response.success.should be_true
    end
  end
end
