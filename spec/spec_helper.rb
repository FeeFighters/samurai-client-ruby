require 'ruby-debug'
Debugger.start
Debugger.settings[:autoeval] = true
Debugger.settings[:autolist] = 5
Debugger.settings[:reload_source_on_change] = true

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

SITE = ENV['site'] || 'https://samurai.feefighters.com/v1/'
USE_MOCK = !ENV['site']

PAYMENT_METHOD_TOKENS = {
  :success => 'b7c966452702282b32a4c65d'
}

RSpec.configure do |c|
  c.before :all do
    @@seed = rand(1000).to_f / 100.0
    #Samurai::Mocks::Base.initialize_mock :report_to_log=>true
  end
  c.before :each do
    @@seed += 1.0
    #Samurai::Mocks::Base.reset!
  end
end

require 'samurai'
Samurai.options = {
  :site => SITE, 
  :merchant_key => ENV['merchant_key'] || 'f4b17359f267915e705fdcb6',
  :merchant_password => ENV['merchant_password'] || 'd7bf19a8aa1051335b83b349',
  :processor_token => ENV['processor_token'] || 'c5823b5f1616ed6c0891d167'
}

