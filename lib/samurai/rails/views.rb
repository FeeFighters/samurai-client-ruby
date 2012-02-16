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
#       :redirect_url => purchase_article_orders_url(@article) %>
# ```
module Samurai::Rails
  class Views
    class << self

      PARTIALS = [ 'payment_form', 'errors', 'transaction' ]

      PARTIALS.each do |partial|
        # _Example:_
        #
        #   def payment_method(attrs={})
        #     {:file=>send("payment_method_file"), :locals=>attrs}
        #   end
        class_eval <<-__METHOD__
          def #{partial}(attrs={})
            {:file=>send("#{partial}_file"), :locals=>attrs}
          end
        __METHOD__

        # _Example:_
        #
        #   def payment_method_file
        #     Pathname.new(__FILE__).dirname.join('../../..', 'app', 'views', 'application', "_payment_method.html.erb").to_s
        #   end
        class_eval <<-__METHOD__
          def #{partial}_file
            Pathname.new('#{__FILE__}').dirname.join('../../..', 'app', 'views', 'application', "_#{partial}.html.erb").to_s
          end
        __METHOD__

        # _Example:_
        #
        #   def payment_method_html
        #     File.read send("payment_method_file")
        #   end
        class_eval <<-__METHOD__
          def #{partial}_html
            File.read send("#{partial}_file")
          end
        __METHOD__
      end

    end
  end
end
