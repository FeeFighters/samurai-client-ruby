require 'spec_helper'

describe "PaymentMethod actions" do

  it "should create a new PaymentMethod using S2S endpoint" do
    Samurai::PaymentMethod.create(
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

  describe 'with errors' do
    before(:each) do
      @params = {
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
        :state => "IL",
      }
    end

    it 'should validate blank card number' do
      pm = Samurai::PaymentMethod.create @params.merge(:card_number=>'')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.card_number'].should == [ 'The card number was blank.' ]
    end
    it 'should validate invalid card number' do
      pm = Samurai::PaymentMethod.create @params.merge(:card_number=>'abc123')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.card_number'].should == [ 'The card number was invalid.' ]
    end
    it 'should validate short card number' do
      pm = Samurai::PaymentMethod.create @params.merge(:card_number=>'1234')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.card_number'].should == [ 'The card number was too short.' ]
    end
    it 'should validate long card number' do
      pm = Samurai::PaymentMethod.create @params.merge(:card_number=>'41111111111111111')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.card_number'].should == [ 'The card number was too long.' ]
    end
    it 'should not validate blank cvv' do
      pm = Samurai::PaymentMethod.create @params.merge(:cvv=>'')
      pm.has_errors?.should be_false
      pm.errors.count.should == 0
    end
    it 'should validate invalid cvv' do
      pm = Samurai::PaymentMethod.create @params.merge(:cvv=>'abc')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.cvv'].should == [ 'The CVV was invalid.' ]
    end
    it 'should validate short cvv' do
      pm = Samurai::PaymentMethod.create @params.merge(:cvv=>'1')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.cvv'].should == [ 'The CVV was too short.' ]
    end
    it 'should validate long cvv' do
      pm = Samurai::PaymentMethod.create @params.merge(:cvv=>'11111')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.cvv'].should == [ 'The CVV was too long.' ]
    end
    it 'should validate blank expiry_month' do
      pm = Samurai::PaymentMethod.create @params.merge(:expiry_month=>'')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.expiry_month'].should == [ 'The expiration month was blank.' ]
    end
    it 'should validate blank expiry_year' do
      pm = Samurai::PaymentMethod.create @params.merge(:expiry_year=>'')
      pm.has_errors?.should be_true
      pm.errors.count.should == 1
      pm.errors['input.expiry_year'].should == [ 'The expiration year was blank.' ]
    end
  end

end
