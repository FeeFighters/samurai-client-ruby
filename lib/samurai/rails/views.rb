require 'pathname'

# Samurai::Rails::Views
# -----------------

# Helper module containing methods designed to be called inside Rails views
# These methods render Samurai partials that ship with the gem,
# making it possible to create a payment form, and display transaction errors, in a single line of code
# eg:
#
# ```ruby
# <%= render Samurai::Rails::Views.errors %>
# <%= render Samurai::Rails::Views.payment_form
#       :redirect_url => purchase_article_orders_url(@article),
#       :sandbox => true %>
# ```
module Samurai::Rails
  class Views
    class << self

      PARTIALS = [ 'payment_form', 'errors', 'transaction' ]

      PARTIALS.each do |partial|
        define_method partial do |attrs|
          attrs ||= {}
          {:file=>send("#{partial}_file"), :locals=>attrs}
        end
        define_method "#{partial}_file" do
          Pathname.new(__FILE__).dirname.join('../../..', 'app', 'views', 'application', "_#{partial}.html.erb").to_s
        end
        define_method "#{partial}_html" do
          File.read send("#{partial}_file")
        end
      end

    end
  end
end
