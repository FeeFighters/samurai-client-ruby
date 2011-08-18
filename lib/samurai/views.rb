require 'pathname'

class Samurai::Views
  class << self

    PARTIALS = [ 'payment_method_form', 'transaction_form', 'errors', 'transaction' ]

    PARTIALS.each do |partial|
      define_method partial do |attrs|
        attrs ||= {}
        {:file=>send("#{partial}_file"), :locals=>attrs}
      end
      define_method "#{partial}_file" do
        Pathname.new(__FILE__).dirname.join('..', '..', 'app', 'views', 'application', "_#{partial}.html.erb").to_s
      end
      define_method "#{partial}_html" do
        File.read(send partial)
      end
    end

  end
end

