module PaypalAdaptivePayments
  ActionDispatch::Routing
  ActionView::Helpers::UrlHelper

=begin
  def self.build_pay_kw(receiver_params, sender_email, user_id, checkout_id)
    ipn_base_url = ENV['IPN_BASE_URL']
    api = PayPal::SDK::AdaptivePayments.new

    pay_hash = {
      :actionType => "PAY",
      :cancelUrl => "https://www.paypal.com/",
      :currencyCode => "USD",
      :senderEmail => 'buyer-5@rendserver.com',
      :feesPayer => "EACHRECEIVER",
      :ipnNotificationUrl => "http://91407476.ngrok.io/api/v1/payments/ipn_notify",
      :receiverList => {
        :receiver => [
          { :amount => 200.0, :email => "guhunderscore-facilitator@gmail.com", primary: true },
          { :amount => 1.0, :email => "lender-1@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-2@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-3@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-4@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-5@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-6@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-7@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-8@rendserver.com", primary: false },
          { :amount => 1.0, :email => "lender-9@rendserver.com", primary: false },
        ]
      },
      :fundingConstraint => {
        :allowedFundingType => {
          :fundingTypeInfo => [
            { :fundingType => "BALANCE" },
            { :fundingType => "CREDITCARD" }
          ] 
        } 
      },
      :returnUrl => "http://91407476.ngrok.io/api/v1/payments/thank_you"
    }

    # pay_hash[:receiverList] = { receiver: receiver_params }
    pay = api.build_pay(pay_hash)
    
    # Make API call & get response
    response = api.pay(pay)
    response_hash = {
      error: 0,
      errors: '',
      success: response.success?
    }
    
    # Access response
    if response.success? 
      # && response.payment_exec_status != "ERROR"
      response_hash[:pay_key] = response.payKey
      response_hash[:url] = api.payment_url(response) # Url to complete payment
      response_hash[:response] = response
    else
      response_error = response.error.first
      response_error_parameter = response_error.parameter.first.value if response_error.parameter.present?
      response_hash[:error] = 1

      response_hash[:errors] = { 
        error_id: response_error.errorId, 
        object: response_error.message, 
        value: response_error_parameter
      }
    end

    response_hash
  end

  def self.refund_kw(pay_key, amount)
    api = PayPal::SDK::AdaptivePayments.new
    merchant_email = api.config.sandbox_email_address

    refund = api.build_refund({
      :currencyCode => "USD",
      :payKey => pay_key,
      :receiverList => {
        :receiver => [
          { :amount => amount, :email => 'guhunderscore-facilitator@gmail.com' }
        ]
      }
    })

    refund_response = api.refund(refund)
  end
=end

  def self.build_pay(receiver_params, sender_email, user_id = nil, checkout_id = nil)
    ipn_base_url = ENV['IPN_BASE_URL']
    api = PayPal::SDK::AdaptivePayments.new

    pay_hash = {
      :actionType => "PAY",
      :cancelUrl => "https://www.paypal.com/",
      :currencyCode => "USD",
      :senderEmail => sender_email,
      :feesPayer => "EACHRECEIVER",
      :ipnNotificationUrl => "#{ipn_base_url}/payments/ipn_notify",
      :receiverList => {},
      :fundingConstraint => {
        :allowedFundingType => {
          :fundingTypeInfo => [
            { :fundingType => "BALANCE" },
            { :fundingType => "CREDITCARD" }
          ] 
        } 
      },
      :returnUrl => "#{ipn_base_url}/payments/thank_you"
    }

    pay_hash[:receiverList] = { receiver: receiver_params }
    pay = api.build_pay(pay_hash)
    
    # Make API call & get response
    response = api.pay(pay)
    response_hash = {
      error: 0,
      errors: '',
      success: response.success?
    }
    
    # Access response
    if response.success? 
      # && response.payment_exec_status != "ERROR"
      response_hash[:pay_key] = response.payKey
      response_hash[:url] = api.payment_url(response) # Url to complete payment
      response_hash[:response] = response
    else
      response_error = response.error.first
      response_error_parameter = response_error.parameter.first.value if response_error.parameter.present?
      response_hash[:error] = 1

      response_hash[:errors] = { 
        error_id: response_error.errorId, 
        object: response_error.message, 
        value: response_error_parameter
      }
    end

    response_hash
  end

  def self.refund(pay_key, amount)
    api = PayPal::SDK::AdaptivePayments.new
    merchant_email = api.config.sandbox_email_address

    refund = api.build_refund({
      :currencyCode => "USD",
      :payKey => pay_key,
      :receiverList => {
        :receiver => [
          { :amount => amount.to_f, :email => merchant_email }
        ]
      }
    })

    # Make API call & get response
    refund_response = api.refund(refund)
  end

  def self.single_payment(amount, sender_email)
    ipn_base_url = ENV['IPN_BASE_URL']
    api = PayPal::SDK::AdaptivePayments.new
    receiver_email = api.config.sandbox_email_address

    pay_hash = {
      :actionType => "PAY",
      :cancelUrl => "https://www.paypal.com/",
      :currencyCode => "USD",
      :senderEmail => sender_email,
      :feesPayer => "EACHRECEIVER",
      :ipnNotificationUrl => "#{ipn_base_url}/payments/ipn_notify",
      :receiverList => {
        :receiver => [
          { :amount => amount.to_f, :email => receiver_email}
        ]
      },
      :fundingConstraint => {
        :allowedFundingType => {
          :fundingTypeInfo => [
            { :fundingType => "BALANCE" },
            { :fundingType => "CREDITCARD" }
          ] 
        } 
      },
      :returnUrl => "#{ipn_base_url}/payments/thank_you"
    }

    pay = api.build_pay(pay_hash)
    
    # Make API call & get response
    response = api.pay(pay)
    response_hash = {
      error: 0,
      errors: '',
      success: response.success?
    }
    
    # Access response
    if response.success? 
      # && response.payment_exec_status != "ERROR"
      response_hash[:pay_key] = response.payKey
      response_hash[:url] = api.payment_url(response) # Url to complete payment
      response_hash[:response] = response
    else
      response_error = response.error.first
      response_error_parameter = response_error.parameter.first.value if response_error.parameter.present?
      response_hash[:error] = 1

      response_hash[:errors] = { 
        error_id: response_error.errorId, 
        object: response_error.message, 
        value: response_error_parameter
      }
    end

    response_hash
  end
end