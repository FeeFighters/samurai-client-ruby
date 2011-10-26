require 'spec_helper'

describe "PaymentMethod actions" do

  it "should create a new PaymentMethod using S2S endpoint" do
    p = Samurai::PaymentMethod.create(
        :city => "Chicago", 
        :zip => "53211", 
        :expiry_month => 03, 
        :cvv => "123", 
        :card_number => "4111111111111111", 
        :address_1 => "1240 W Monroe #1", 
        :address_2 => "", 
        :last_name => "harper", 
        :expiry_year => "2015", 
        :first_name => "sean", 
        :state => "IL")
  end

end
