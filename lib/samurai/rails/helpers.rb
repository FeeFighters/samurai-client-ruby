require 'pathname'

module Samurai::Rails
  module Helpers

    def setup_for_transparent_redirect(params)
      @transaction = Samurai::Transaction.find params[:reference_id] unless params[:reference_id].blank?
      @payment_method = Samurai::PaymentMethod.for_transparent_redirect(params)
    end

    def load_and_verify_payment_method(params)
      if params[:payment_method_token].blank?
        @payment_method = Samurai::PaymentMethod.new :is_sensitive_data_valid=>false
      else
        @payment_method = Samurai::PaymentMethod.find params[:payment_method_token]
        @payment_method = nil if @payment_method && !@payment_method.is_sensitive_data_valid?
      end
      @payment_method
    end

    def payment_method_params
      { :payment_method_token => params[:payment_method_token] }.tap do |_params|
        _params[:reference_id] = @transaction.reference_id if @transaction
      end
    end

  end
end
