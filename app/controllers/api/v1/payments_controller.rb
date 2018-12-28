class Api::V1::PaymentsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication, except: [:ipn_notify, :thank_you]
  before_action :set_checkout, only: [:pay_cancel, :ipn_notify]
  before_action :get_verified_status, only: [:create, :update]
  # before_action :check_payment_status, only: [:create, :update]
  before_action :set_payment, only: [:update, :delete]

  respond_to :json

  api :GET, "/v1/payments/by_user", "Get list of all payment information based on user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :status, String, desc: "Status of the paypal emair('default')"
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all payment informations based on user"

  def by_user
    @payments = @user.payments.order(id: :desc)
  end

  api :POST, "/v1/payments/create", "Create a new payment information based on current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :paypal_email, String, desc: "PayPal Email", required: true
  param :status, String, desc: "Status of the paypal email('default', 'inactive')"
  description "Create a new payment information based on current user"

  def create
    if @response[:success]
      is_exists = Payment.where(paypal_email: @response[:user_info][:paypal_email]).exists?

      if is_exists
        @error = 1
        @errors = 'Your payment already exist'
      else
        payment = Payment.new(paypal_email: @response[:user_info][:paypal_email], user_id: @user.id, aasm_state: params[:status])

        if payment.save
          @payment = payment
          @response = @response
        else
          @error = 1
          @errors = payment.error
        end
      end
    else
      @error = request[:error]
      @errors = request[:errors]
    end
  end

  api :POST, "/v1/payments/update", "Update a new payment information based on current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :payment_id, String, desc: "Payment ID", required: true
  param :paypal_email, String, desc: "PayPal Email", required: true
  param :status, String, desc: "Status of the paypal email('default', or 'inactive')", required: true
  description "Create a new payment information based on current user"

  def update
    if @response[:success]
      is_exists = Payment.where(paypal_email: params[:paypal_email]).exists?

      if is_exists
        @error = 1
        @errors = 'Your payment already exist'
      else
        merge_params = payment_params.merge(aasm_state: params[:status])

        if @payment.update(merge_params)
          current_default_payment = Payment.where('user_id = ? AND aasm_state = ? AND id != ?', @user.id, 'default', @payment.id).first

          if current_default_payment.present? && @user.payments.default.size > 1
            current_default_payment.update(aasm_state: :inactive)
          end

          @response = @response
        else
          @error = 1
          @errors = payment.error
        end
      end

    else
      @error = request[:error]
      @errors = request[:errors]
    end
  end

  api :POST, "/v1/payments/update_status", "Update status a new payment information based on current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :payment_id, String, desc: "Payment ID", required: true
  param :status, String, desc: "Status of the paypal email('default' or 'inactive')", required: true
  description "Create a new payment information based on current user"

  def update_status
    current_payment = @user.payments.default.first

    if current_payment
      if current_payment.update(aasm_state: :inactive)
        payment = Payment.find_by(id: params[:payment_id])

        if payment.update_attributes(aasm_state: params[:status])
          @payment = payment
        else
          @error = 1
          @errors = payment.error
        end
      else
        @error = 1
        @errors = current_payment.error
      end
    else
      @object = "Payment Information"
      render "api/v1/errors/404", status: 404
    end
  end

  api :POST, "/v1/payments/delete", "User has ability to remove payment information"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :payment_id, String, desc: "Product ID Lender wants to remove it from favourite", required: true
  description "Ability for user to remove favourite from a product"

  def delete
    if @payment.aasm_state.eql? 'default'
      @error = 1
      @errors = "You can't remove this payment information because this payment set as default"
    else
      unless @payment.destroy
        @object = "Payment"
        render "api/v1/errors/404", status: 404
      end
    end
  end

  api :POST, "/v1/payments/lender/give_refund", "The lender give refund to the renter"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :product_id, String, desc: "Product ID", required: true
  param :renter_id, String, desc: "User ID of the renter", required: true
  description "The lender give refund to the renter"

  def give_refund
    recipient = User.find_by(id: params[:renter_id])
    @product = Product.find_by(id: params[:product_id])
    body_message = "#{@product.user.full_name.titleize} request to you accept return of the deposit"

    #
    # create activity includes send notification to mobile
    #
    activity = PublicActivity::Activity.new

    response_notif = activity.create_notification(
      key: 'refund.give_by_lender',
      owner: @user,
      recipient: recipient,
      notification_type: 'give_refund',
      title_message: 'Refund Deposit',
      body_message: body_message,
      another_parameters: {
        product_id: @product.id,
        product_name: @product.name
      },
      status: 201
    )
  end

  api :POST, "/v1/payments/renter/accepted_refund", "The renter received refund from the lender"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :product_id, String, desc: "Product ID", required: true
  description "The renter received refund from the lender"

  def accepted_refund
    product = Product.renter_accepeted_refund(params[:product_id])

    if product
      refund_payment = PaypalAdaptivePayments.refund(product.pay_key, product.deposit)

      if refund_payment.success?
        @refund_info = refund_payment.refundInfoList.refundInfo
        @time = refund_payment.responseEnvelope.timestamp.strftime("%B %d, %Y %H:%M:%S")
        body_message = "#{@user.full_name.titleize} already accepted refund of the deposit"

        #
        # create activity includes send notification to mobile
        #
        activity = PublicActivity::Activity.new

        response_notif = activity.create_notification(
          key: 'refund.accepted_by_renter',
          owner: @user,
          recipient: product.user,
          notification_type: 'accepted_refund',
          title_message: 'Accepted Deposit',
          body_message: body_message,
          status: 201
        )
      else
        error_response = refund_payment.error.first

        @error = 1
        @errors = {
          error_id: error_response.errorId,
          object: error_response.message,
          status: 422
        }
      end
    else
      @object = "Product ID based on your account"
      render "api/v1/errors/404", status: 404
    end
  end

  def ipn_notify
    response = request.parameters

    if response["status"].eql?('COMPLETED') && response['reason_code'].nil?
      if @checkout
        payment_per_lender_id = @checkout.generate_payment_per_lender_hash(:lender_id)

        #
        # update user
        #
        payment_per_lender_id.each do |lender|
          user = User.find(lender[:id])
          user.balance += lender[:amount]
          user.save
        end

        #
        # create rent histories
        #
        @checkout.checkout_items.includes(:product).each do |checkout_item|
          lender = checkout_item.product.user
          lender_id = lender.id
          renter_id = @checkout.user_id
          product_id = checkout_item.product_id
          rent_time = checkout_item.rent_time

          rent_history = RentHistory.create(
            renter_id: renter_id,
            lender_id: lender_id,
            product_id: product_id,
            rent_time: rent_time,
            rent_type: :product,
            price: checkout_item.price,
            checkout_id: @checkout.id,
            checkout_item_id: checkout_item.id,
            status: 201
          )

          if rent_history
            rent_history.product.update(
              aasm_state: :not_available,
              rent_status: :rent,
              status: 200
            )
          end
        end

        lender_ids = []
        @checkout.checkout_items.map { |checkout_item| lender_ids << checkout_item.product.user_id }

        if lender_ids
          lender_ids.uniq.each do |lender_id|
            recipient = User.find_by(id: lender_id)

            #
            # create activity includes send notification to mobile
            #
            activity = PublicActivity::Activity.new
            body_message = "#{@checkout.user.full_name} waiting for approved transaction"

            response_notif = activity.create_notification(
              key: 'checkout.confirmation',
              owner: @checkout.user,
              recipient: recipient,
              notification_type: 'rent_request',
              title_message: 'Rent Request',
              body_message: body_message,
              status: 201
            )
          end
        else
          puts @checkout.checkout_items.pluck(:product_id)
        end

        #
        # update checkout
        #
        transaction_id = response[:transaction]["0"][".id"]
        @checkout.update_attributes(transaction_id: transaction_id, pay_status: :paid)
      end
    else
      logger.error response
    end

    render nothing: true, status: 200
  end

  def thank_you
    render nothing: true, status: 200
  end

  private
    def set_checkout
      @checkout = Checkout.find_by(pay_key: payment_params[:pay_key])
    end

    def set_payment
      @payment = Payment.find_by(id: params[:payment_id])
      render json: {status: 200}

      unless @payment
        @object = "Payment"
        render "api/v1/errors/404", status: 404
      end
    end

    # def check_payment_status
    #   @status = Payment.check_status(payment_params[:status])
    # end

    def get_verified_status
      @response = PaypalAdaptiveAccounts.get_verified_status(payment_params[:paypal_email])
    end

    def payment_params
      params.permit(:pay_key, :paypal_email, :status, :aasm_state)
    end
end