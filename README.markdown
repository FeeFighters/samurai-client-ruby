Samurai
=======

The Samurai merchant gem give you a nice set of ruby object to play with
instead of hacking the Samurai API yourself. You'll need a merchant account 
with samurai.feefighters.com and your credentials and you'll need your
application to track a few identifying tokens with your. 


Installation
------------

Install Samurai just like any other gem. In Rails3 add the gem to your Gemfile:

    gem "samurai"

then run:

    bundle install

In Rails2 add the gem to your environment.rb:

    config.gem "samurai"

then run:

    rake gems:install


Configuration
-------------

Set the Samurai.options hash, after the gem has loaded and before you'll use 
it. Typically this belongs in your environment.rb file or it's own initializer. 

    config.after_initialize do
      Samurai.options = {
        :merchant_key => 'your_merchant_key', 
        :merchant_password => 'your_merchant_password', 
        :gateway_token => 'your_default_gateway_token'
      }
    end

The :gateway_token param is optional. If you set it, 
`Samurai::Gateway.the_gateway` will return the gateway with this token. You
can always call `Samurai::Gateway.find('an_arbitrary_gateway_token')` to 
retrieve any of your gateways.


Payment Methods
---------------

A Payment Method is created each time a user stores their billing information
in Samurai. 

### Creating Payment Methods

To let your customers create a Payment Method, place a credit card
entry form on your site like the one below.

    <form action="https://api.ubergateway.com/v1/payment_methods" method="POST">
      <fieldset>
        <input name="redirect_url" type="hidden" value="http://yourdomain.com/anywhere" />
        <input name="merchant_key" type="hidden" value="[Your Merchant Key]" />

        <!-- Before populating the ‘custom’ parameter, remember to escape reserved xml characters 
             like <, > and & into their safe counterparts like &lt;, &gt; and &amp; -->
        <input name="custom" type="hidden" value="Any value you want us to save with this payment method" />

        <label for="credit_card_first_name">First name</label>
        <input id="credit_card_first_name" name="credit_card[first_name]" type="text" />

        <label for="credit_card_last_name">Last name</label>
        <input id="credit_card_last_name" name="credit_card[last_name]" type="text" />

        <label for="credit_card_address_1">Address 1</label>
        <input id="credit_card_address_1" name="credit_card[address_1]" type="text" />

        <label for="credit_card_address_2">Address 2</label>
        <input id="credit_card_address_2" name="credit_card[address_2]" type="text" />

        <label for="credit_card_city">City</label>
        <input id="credit_card_city" name="credit_card[city]" type="text" />

        <label for="credit_card_state">State</label>
        <input id="credit_card_state" name="credit_card[state]" type="text" />

        <label for="credit_card_zip">Zip</label>
        <input id="credit_card_zip" name="credit_card[zip]" type="text" />

        <label for="credit_card_card_type">Card Type</label>
        <select id="credit_card_card_type" name="credit_card[card_type]">
          <option value="visa">Visa</option>
          <option value="master">MasterCard</option>
        </select>

        <label for="credit_card_card_number">Card Number</label>
        <input id="credit_card_card_number" name="credit_card[card_number]" type="text" />

        <label for="credit_card_verification_value">Security Code</label>
        <input id="credit_card_verification_value" name="credit_card[cvv]" type="text" />

        <label for="credit_card_month">Expires on</label>
        <input id="credit_card_month" name="credit_card[expiry_month]" type="text" />
        <input id="credit_card_year" name="credit_card[expiry_year]" type="text" />

        <button type="submit">Submit Payment</button>
      </fieldset>
    </form>

After the form submits to Samurai, the user's browser will be returned to the 
URL that you specify in the redirect_url field, with an additional query 
parameter containing the `payment_method_token`. You should save the 
`payment_method_token` and use it from this point forward.

### Fetching a Payment Method

To retrieve the payment method and ensure that the sensitive data is valid: 

    payment_method = Samurai::PaymentMethod.find(payment_method_token)
    payment_method.is_sensitive_data_valid # => true if the credit_card[card_number] passed checksum
                                           #    and the cvv (if included) is a number of 3 or 4 digits

**NB:** Samurai will not validate any non-sensitive data so it is up to your 
application to perform any additional validation on the payment_method.

### Updating Payment Methods

You can update the payment method by directly updating its properties or by 
loading it from a set of attributes and then saving the object:

    payment_method.first_name = 'Graeme'
    payment_method.save

OR

    payment_method.load(hash_of_credit_card_values)
    payment_method.save

### Retaining and Redacting Payment Methods

Unless you create a transaction on a payment method right away, that payment
method will be purged from Samurai. If you want to hang on to a payment method
for a while before making an authorization or purchase on it, you must retain it:

    payment_method.retain

If you are finished with a payment method that you have either previously retained
or done one or more transactions with, you may redact the payment method. This 
removes any sensitive information from Samurai related to the payment method, 
but it still keeps the transaction data for reference. No further transactions
can be processed on a redacted payment method. 

    payment_method.redact


Processing Transactions
-----------------------

Your application needs to be prepared to track several identifiers. The payment_method_token
identifies a payment method stored in Samurai. Each transaction processed
has a transaction_token that identifies a group of transactions (initiated with
a purchase or authorization) and a reference_id that identifies the specific
transaction. 

### Purchases and Authorizations

When you want to start to process a new purchase or authorization on a payment 
method, Samurai needs to know which of your gateways you want to use. You can 
initiate a purchase (if your gateway supports it) or an authorization against 
a gateway by:

    gateway = Samurai::Gateway.the_gateway # if you set Samurai.options[:gateway_token]
    gateway = Samurai::Gateway.find('a_gateway_token') # if you have multiple gateways 
    purchase = gateway.purchase(payment_method_token, amount, options)
    purchase_reference_id = purchase.reference_id # save this value, you can find the transaction with it later
    
An authorization is created the same way: 
    
    authorization = gateway.authorize(payment_method_token, amount, options)
    authorization_reference_id = authorization.reference_id # save this value, you can find the transaction with it later

You can specify options for either transaction type. Options is a hash that may contain:

* descriptor: a string description of the charge
* billing_reference: a string reference for the transaction
* customer_reference: a string that identifies the customer to your application
* custom: a custom value that Samurai will store but not forward to the gateway

### Capturing an Authorization

An authorization only puts a hold on the funds that you specified. It won't 
capture the money. You'll need to call capture on the authorization to do this.

    authorization = Samurai::Transaction.find(authorization_reference_id) # get the authorization created previously
    capture = authorization.capture # captures the full amount of the authorization

### Voiding a Transaction

A transaction that was recently created can be voided, if is has not been 
settled. A transaction that has settled has already deposited funds into your
merchant account. 

    transaction = Samurai::Transaction.find(purchase_reference_id) # gets the purchase created before previously
    void_transaction = transaction.void # voids the transaction

### Crediting a Transaction

Once a captured authorization or purchase has settled, you need to credit the 
transaction if you want to reverse a charge. 

    purchase = Samurai::Transaction.find(purchase_reference_id)
    credit = purchse.credit # credits the full amount of the original purchase


ActiveResource::Base
--------------------

Samurai is dependent on the ActiveResource gem version 2.2.2 or greater. Any
Samurai::Base objects descend from ActiveResource::Base, so you can call any
ActiveResource instance or class methods on the object or their classes. 
