require 'spec_helper'

describe "message responses" do

  it 'should display processor_transaction_success' do
    message = Samurai::Message.new(:subclass=>'info', :context=>'processor.transaction', :key=>'success')
    message.description.should == 'The transaction was successful.'
  end    
  it 'should display processor_transaction_declined' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'processor.transaction', :key=>'declined')
    message.description.should == 'The card was declined.'
  end    
  it 'should display processor_issuer_call' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'processor.issuer', :key=>'call')
    message.description.should == 'Call the card issuer for further instructions.'
  end  
  it 'should display processor_issuer_unavailable' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'processor.issuer', :key=>'unavailable')
    message.description.should == 'The authorization did not respond within the alloted time.'
  end  
  it 'should display input_card_number_invalid' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'input.card_number', :key=>'invalid')
    message.description.should == 'The card number was invalid.'
  end  
  it 'should display input_expiry_month_invalid' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'input.expiry_month', :key=>'invalid')
    message.description.should == 'The expiration date month was invalid, or prior to today.'
  end  
  it 'should display input_expiry_year_invalid' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'input.expiry_year', :key=>'invalid')
    message.description.should == 'The expiration date year was invalid, or prior to today.'
  end  
  it 'should display input_amount_invalid' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'input.amount', :key=>'invalid')
    message.description.should == 'The transaction amount was invalid.'
  end  
  it 'should display processor_transaction_declined_insufficient_funds' do
    message = Samurai::Message.new(:subclass=>'error', :context=>'processor.transaction', :key=>'declined_insufficient_funds')
    message.description.should == 'The transaction was declined due to insufficient funds.'
  end
  
end
