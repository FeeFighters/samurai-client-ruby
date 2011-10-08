Samurai
=======

If you are an online merchant and using FeeFighters' Samurai gateway, this gem will
make your life easy. Integrate with the samurai.feefighters.com portal and
process transactions.


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
        :processor_token => 'your_default_processor_token'
      }
    end

The :processor_token param is optional. If you set it,
`Samurai::Processor.the_processor` will return the processor with this token. You
can always call `Samurai::Processor.find('an_arbitrary_processor_token')` to
retrieve any of your processors.


Samurai API Reference
---------------------

See the [API Reference](https://samurai.feefighters.com/developers/) for a full explanation of how this gem works with the Samurai API.


ActiveResource::Base
--------------------

Samurai is dependent on the ActiveResource gem version 2.2.2 or greater. Any
Samurai::Base objects descend from ActiveResource::Base, so you can call any
ActiveResource instance or class methods on the object or their classes. 
