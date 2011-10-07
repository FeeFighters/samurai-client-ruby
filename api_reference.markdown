## Overview

The Samurai API uses simple XML payloads transmitted over 256-bit encrypted <code class="post request">HTTPS POST</code> with Basic Authentication.  The Samurai ruby gem uses ActiveResource to handle all of the authentication & XML serialization.  It encapsulates the API calls as simple method calls on PaymentMethod and Transaction models, so you shouldn't need to think about the details of the actual API.



## Getting Started

To use the Samurai API, you'll need a <mark>Merchant Key</mark>, <mark>Merchant Password</mark> and a <mark>Processor Token</mark>.
[Sign up for an account](https://samurai.feefighters.com/users/sign_up) to get started.


### Samurai Credentials

Once you have these credentials, you can add them to an initializer in your Rails app (or anywhere after requiring the gem in a Sinatra/plain-ol'-ruby app):

```ruby
require 'samurai'
Samurai.options = {
  :merchant_key => '[merchant_key]',
  :merchant_password => '[merchant_password]',
  :processor_token => '[processor_token]',
}
```



## Payment Methods

Each time a user stores their billing information in the Samurai system, we call it a <mark>Payment Method</mark>.

Our <a href="/transparent-redirect">transparent redirect</a> uses a simple HTML form on your website that submits your user’s billing information directly to us over SSL so that you never have to worry about handling credit card data yourself. We’ll quickly store the sensitive information, tokenize it for you and return the user to a page on your website of your choice with the new <mark>Payment Method Token</mark>.

From that point forward, you always refer to the Payment Method Token anytime you’d like to use that billing information for anything.

### Creating a Payment Method (via Transparent Redirect)

The Samurai ruby gem makes setting up a transparent redirect form extremely simple.  We have included some handy helper methods to set everything up for you:

#### In your controller:

```ruby
def payment_form
  setup_for_transparent_redirect(params)
end
```

#### In your view:

```ruby
<%= render Samurai::Rails::Views.errors %>
<%= render Samurai::Rails::Views.payment_form :redirect_url => your_redirect_url,
                                              :sandbox => true %>
```


Here’s an example of the form that will be added to your view.  Key fields are highlighted in bold text, the style and labels are yours to configure however you like.

```html
<form action="https://api.samurai.feefighters.com/v1/payment_methods" method="POST">
  <fieldset>
    <input name="redirect_url" type="hidden" value="http://yourdomain.com/anywhere" />
    <input name="merchant_key" type="hidden" value="[merchant_key]" />
    <input name="sandbox" type="hidden" value="true" />

    <!-- Before populating the ‘custom’ parameter, remember to escape reserved characters
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

    <label for="credit_card_number">Card Number</label>
    <input id="credit_card_number" name="credit_card[card_number]" type="text" />

    <label for="credit_card_verification_value">Security Code</label>
    <input id="credit_card_verification_value" name="credit_card[cvv]" type="text" />

    <label for="credit_card_month">Expires on</label>
    <input id="credit_card_month" name="credit_card[expiry_month]" type="text" />
    <input id="credit_card_year" name="credit_card[expiry_year]" type="text" />

    <button type='submit'>Submit Payment</button>
  </fieldset>
</form>
```

When we return the user to the URL that you specified in the `redirect_url` field, we’ll append the new Payment Method Token to the query string. You should save the Payment Method Token and use it from this point forward.

The following fields are required by Samurai, and submitting a Payment Method without them will trigger an error: `card_number`, `cvv`, `expiry_month`, `expiry_year`. However, in practice, most Processors will also require `first_name`, `last_name`, and the address fields as well. In that case, leaving these fields blank will trigger an error from the Processor when the Payment Method is used to create a transaction.

The `sandbox` field is a boolean that specifies whether the payment method is intended to be used with a <mark>Sandbox Processor</mark>.  Sandbox processors can only process transactions with sandbox Payment Methods, and vice versa.  You may omit this field in production, the default value is "false".

### Update a Payment Method (via Transparent Redirect)

Updating a payment method is very similar to creating a new one.  (in fact, it is so similar that we've considered calling it "regenerating" instead)

To update a payment method, we add an additional hidden input `payment_method_token` for the desired payment method to be regenerated via the transparent redirect. Key fields are highlighted in bold text, the style and labels are yours to configure however you like. All credit card related fields are optional along with the custom and sandbox fields.

The semantics around regenerating a Payment Method using an existing `payment_method_token` are:

* If `field` does not exist, use old Payment Method value
* If `field` exists, but is invalid, use old Payment Method value
* If `field` exists, and is valid (or has no validations), replace old Payment Method value
  * __The only fields that are required by Samurai are `card_number, cvv, expiry_month, expiry_year`. For the other fields, blank values will be considered valid.__

This is designed to allow you to load the old Payment Method data into your form fields, including the sanitized card number (`last_four_digits`) and cvv values. Then, when the user changes any of the fields and submits the form it should regenerate the new Payment Method keeping the old data intact and updating only the fresh data.

**_The bottom line:_ If you are using the Samurai ruby gem with the sample code above, you don't need to do anything to support updating a payment method.  Your customers will be able to view Payment Method validation errors, act on them, and re-submit with new data.**


### Fetching a Payment Method

Since the transparent redirect form submits directly to Samurai, you don’t get to see the data that the user entered until you read it from us.  This way, you can see if the user made any input errors and ask them to resubmit the transparent redirect form if necessary.

We’ll only send you non-sensitive data, so you will no be able to pre-populate the sensitive fields (card number and cvv) in the resubmission form.

```ruby
@payment_method = Samurai::PaymentMethod.find params[:payment_method_token]
@payment_method.is_sensitive_data_valid # => true if the credit_card[card_number] passed checksum
                                        #    and the cvv (if included) is a number of 3 or 4 digits
```

**NOTE:** Samurai will not validate any non-sensitive data so it is up to your
application to perform any additional validation on the payment_method.


### Retaining a Payment Method

Once you have determined that you’d like to keep a Payment Method in the Samurai vault, you must tell us to retain it.  If you don’t explicitly issue a retain command, we will delete the Payment Method within 48 hours in order to comply with PCI DSS requirement 3.1, which states:

> "3.1  Keep cardholder data storage to a minimum. Develop a data retention and disposal policy. Limit storage amount and retention time to that which is required for business, legal, and/or regulatory purposes, as documented in the data retention policy."

However, if you perform a purchase or authorize transaction with a Payment Method, it will be automatically retained for future use.

```ruby
@payment_method.retain
```

### Redacting a Payment Method

It’s important that you redact payment methods whenever you know you won’t need them anymore.  Typically this is after the credit card’s expiration date or when your user has supplied you with a different card to use.

```ruby
@payment_method.redact
```



## Processing Payments (Simple)

When you’re ready to process a payment, the simplest way to do so is with the `purchase` method.

```ruby
@purchase = Samurai::Processor.purchase(payment_method_token, 100.0, {
              :billing_reference =>   'billing data',
              :customer_reference =>  'customer data',
              :custom =>              'custom data',
              :descriptor =>          'descriptor',
            })
```

The following optional parameters are available on a purchase transaction:

* `descriptor`: descriptor for the transaction
* `custom`: custom data, this data does not get passed to the processor, it is stored within api.samurai.feefighters.com only
* `customer_reference`: an identifier for the customer, this will appear in the processor if supported
* `billing_reference`: an identifier for the purchase, this will appear in the processor if supported



## Processing Payments (Complex)

In some cases, a simple purchase isn’t flexible enough.  The alternative is to do an Authorize first, then a Capture if you want to process a previously authorized transaction or a Void if you want to cancel it.  Be sure to save the `transaction_token` that is returned to you from an authorization because you’ll need it to capture or void the transaction.

### Authorize

An Authorize doesn’t charge your user’s credit card.  It only reserves the transaction amount and it has the added benefit of telling you if your processor thinks that the transaction will succeed whenever you Capture it.

```ruby
@authorization = Samurai::Processor.authorize(payment_method_token, 1.0, {
              :billing_reference =>   'billing data',
              :customer_reference =>  'customer data',
              :custom =>              'custom data',
              :descriptor =>          'descriptor',
            })
```

See the [purchase transaction](#processing-payments-simple) documentation for details on the optional data parameters.

### Capture

You can only execute a capture on a transaction that has previously been authorized.  You’ll need the Transaction Token value from your Authorize command to construct the URL to use for capturing it.

```ruby
@authorization = Samurai::Transaction.find(transaction_token)  # get the authorization created previously
@capture = @authorization.capture  # capture the full amount (or specify an optional amount)
```

### Void

You can only execute a void on a transaction that has previously been captured or purchased.  You’ll need the Transaction Token value from your Authorize command to construct the URL to use for voiding it.

**A transaction can only be voided if it has not settled yet.** Settlement typically takes 24 hours, but it depends on the processor connection you are using. For this reason, it is often convenient to use the [Reverse](#reverse) instead.

```ruby
@transaction = Samurai::Transaction.find(transaction_token) # get the transaction
@void = @transaction.void
```

### Credit

You can only execute a credit on a transaction that has previously been captured or purchased.  You’ll need the Transaction Token value from your Authorize command to construct the URL to use for crediting it.

**A transaction can only be credited if it has settled.** Settlement typically takes 24 hours, but it depends on the processor connection you are using. For this reason, it is often convenient to use the [Reverse](#reverse) instead.

```ruby
@transaction = Samurai::Transaction.find(transaction_token) # get the transaction
@credit = @transaction.credit  # credit the full amount (or specify an optional amount)
```

### Reverse

You can only execute a reverse on a transaction that has previously been captured or purchased.  You’ll need the Transaction Token value from your Authorize command to construct the URL to use for reversing it.

*A reverse is equivalent to a void, followed by a full-value credit if the void is unsuccessful.*

```ruby
@transaction = Samurai::Transaction.find(transaction_token) # get the transaction
@reverse = @transaction.reverse
```



## Fetching a Transaction

Each time you use one of the transaction processing functions (purchase, authorize, capture, void, credit) you are given a `reference_id` that uniquely identifies the transaction for reporting purposes.  If you want to retrieve transaction data, you can use this fetch method on the `reference_id`.

```ruby
@transaction = Samurai::Transaction.find reference_id
```



## Server-to-Server Payment Method API

We don't typically recommend using our server-to-server API for creating/updating Payment Methods, because it requires credit card data to pass through your server and exposes you to a much greater PCI compliance & risk liability.

However, there are situations where using the server-to-server API is appropriate, such as integrating a server that is already PCI-secure with Samurai or if you need to perform complex transactions and don't mind bearing the burden of greater complaince and risk.


### Creating a Payment Method (S2S)

_Documentation coming soon._

### Updating a Payment Method (S2S)

Any payment method that has been retained (either explicitly via the retain function or implicitly via purchase or authorize) cannot be updated any longer.

_Documentation coming soon._



## Error Messages

_Documentation coming soon._





