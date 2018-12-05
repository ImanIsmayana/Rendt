module PaypalAdaptiveAccounts
  def self.get_verified_status(paypal_email)
    api = PayPal::SDK::AdaptiveAccounts::API.new

    #
    # Build request object
    #
    request = api.build_get_verified_status({
      :emailAddress => paypal_email,
      :matchCriteria => "NONE" # default
    })

    #
    # Make API call & get response
    #
    response = api.get_verified_status(request)
    
    response_hash = {
      error: 0,
      errors: '',
      success: response.success?
    }

    #
    # Access Response
    #
    if response.success?
      response_hash[:account_status] = response.accountStatus
      response_hash[:country_code] = response.countryCode
      response_info_name, response_email_address = [response.userInfo.name, response.userInfo.emailAddress]

      response_hash[:user_info] = {
        paypal_email: response_email_address,
        first_name: response_info_name.firstName,
        last_name: response_info_name.lastName
      }
    else
      response_hash[:error] = 1
      response_error = response.error.first

      response_hash[:errors] = {
        error_id: response_error.errorId,
        object: response_error.message
      }
    end

    response_hash
  end
end