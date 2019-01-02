class Api::V1::CheckoutsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token

  before_action :check_user_authentication
  before_action :set_product, only: :create
  before_action :set_payment_information, only: :update_payment_information
  before_action :get_checkout, only: [:items, :update_rent_duration, :update_payment_information,
    :confirmation, :review]

  respond_to :json

  api :POST, "/v1/checkouts/create", "Create a new checkout based on selected items"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will add product to cart", required: true
  param :product_ids, String, desc: "Product IDs to checkout - separate by comma (,)"
  param :junkyard_product_ids, String, desc: "Junkyard product IDs to checkout - separate by comma (,)"
  description "Create a new checkout based on selected items"

  # OPTIMIZE is API cannot send product_ids in array format? we could use nested attributes when creating checkout and its items
  def create
    product = create_product(@products, params[:product_ids]) if @products.present?
    junkyard_product = create_junkyard(@junkyard_products, params[:junkyard_product_ids]) if @junkyard_products.present?

    checkout_product = Checkout.includes(:checkout_items).find(product) if @products.present?
    checkout_junkyard = Checkout.includes(:checkout_items).find(junkyard_product) if @junkyard_products.present?

    @checkout = Checkout.get_checkout_junkyard_or_product(checkout_product, checkout_junkyard)
  end

  # def all
  #   @checkouts = Checkout.all
  # end

  api :GET, "/v1/checkouts/items", "Get list of all transaction history of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :checkout_id, String, desc: "Checkout ID of items to be displayed", required: true
  description "Get list of all items from a checkout"

  def items
    @checkout_items = @checkout.checkout_items
  end

  api :POST, "/v1/checkouts/update_rent_duration", "Update checkout rent item duration"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will add product to cart", required: true
  param :checkout_id, String, desc: "Checkout ID of items to be updated", required: true
  param :rent_durations, String, desc: "Rent duration per product ['1h', '4h', '1d', '1w'] - separate by comma (,)", required: true
  description "Update checkout rent item duration"

  # OPTIMIZE I don't think it's best practice using index of array and we can use checkout_item.
  # update then create new private method to declare the parameters
  def update_rent_duration
    rent_durations = params[:rent_durations].split(",")
    total_price = 0

    @checkout.checkout_items.each_with_index do |checkout_item, index|
      checkout_item.update_attributes(duration_code: rent_durations[index])
      total_price += checkout_item.total_price
    end

    #
    # update total paid on checkout record
    @checkout.update(total_paid: total_price)
  end

  api :POST, "/v1/checkouts/update_payment_information", "Update checkout payment information"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will add product to cart", required: true
  param :checkout_id, String, desc: "Checkout ID of items to be updated", required: true
  param :payment_id, String, desc: "Payment ID of payment information which will get charged", required: true
  description "Update checkout payment information"

  def update_payment_information
    @checkout.update(payment_id: params[:payment_id])
  end

  api :GET, "/v1/checkouts/update_status_item", "Update status item in rent histories"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :product_id, String, desc: "Product ID", required: true
  param :status, String, desc: "Status item or product('pending' or 'approved')", required: true
  description "Update status item in checkouts"

  def update_status_item
    checkout_item = CheckoutItem.find_by(product_id: params[:product_id])

    if checkout_item.update(aasm_state: params[:status])
      product = checkout_item.product
      renter = checkout_item.checkout.user

      activity = PublicActivity::Activity.new
      body_message = "Item #{product.name} already approved"

      activity.create_notification(
        key: 'checkout.approved_rent_request',
        owner: @user,
        recipient: renter,
        notification_type: 'rent_request',
        title_message: 'Approved Rent Request ',
        body_message: body_message,
        another_parameters: {
          product_id: product.id,
          product_name: product.name
        },
        status: 200
      )

    else
      @error = 1
      @errors = checkout_item.errors
      render json: {status: 422}
    end
  end

  api "POST", "v1/checkout/confirmation", "Update checkout confirmation"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will add product to cart", required: true
  param :checkout_id, String, desc: "Checkout ID of items to be displayed"
  param :checkout_junkyard_id, String, desc: "Checkout Junkyard ID of items to be displayed"
  param :checkout_type, String, desc: "Checkout type product, junkyard or both (product,junkyard, both)", required: true
  description "Checkout confirmation about the items to be rented and payment information will be used"

  def confirmation
    checkout_type = params[:checkout_type].split(',')

    if params[:checkout_type].eql?('product') || params[:checkout_type].eql?('both')
      request = @checkout.request_single_payments

      if request[:success]
        @payments_response = {
          url: request[:url],
          pay_key: request[:pay_key],
          status: 200
        }

        @checkout.update_attributes(pay_key: request[:pay_key], payment_type: 'paypal') #, aasm_state: :approved)
      else
        @error = request[:error]
        @errors = request[:errors]
      end
    end

    if params[:checkout_type].eql? 'junkyard' || params[:checkout_type].eql?('both')
      @checkout_junkyard.update_attributes(pay_status: :free)
      create_rent_histories_junkyard(@checkout_junkyard)
    end
  end

  api :GET, "/v1/checkouts/review", "Review rent information before finish checkout process"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :checkout_id, String, desc: "Checkout ID of items to be displayed"
  param :checkout_junkyard_id, String, desc: "Checkout Junkyard ID of items to be displayed"
  param :checkout_type, String, desc: "Checkout type product, junkyard or both (product,junkyard, both)", required: true
  description "Get list of all information related to current checkout before finish submit checkout process"

  def review
    checkout, checkout_junkyard = [@checkout, @checkout_junkyard]
    @checkout_result = Checkout.get_review_checkout_junkyard_or_product(checkout, checkout_junkyard)
  end

  private
    def set_product
      if params[:product_ids].present?
        @products = Product.where("id IN (?) AND aasm_state = ?",
          params[:product_ids].split(","), :available)
      end

      if params[:junkyard_product_ids].present?
        @junkyard_products =
          JunkyardProduct.where("id IN (?) AND aasm_state = ?",
            params[:junkyard_product_ids].split(","), :available)
      end

      unless @products || @junkyard_products
        if @products && @products.empty? || @junkyard_products && @junkyard_products.empty?
          @object = 'Product or Junkyard'
          render "api/v1/errors/404", status: 404
        end
      end
    end

    def set_payment_information
      @payment = Payment.find_by(id: params[:payment_id])
      is_exists?(@payment, 'payment')
    end

    def get_checkout
      if params[:checkout_type]
        if params[:checkout_type].eql? 'both'
          set_checkout
          set_checkout_junkyard
        elsif  params[:checkout_type].eql? 'product'
          set_checkout
        else
          set_checkout_junkyard
        end
      else
        set_checkout
      end
    end

    def set_checkout
      @checkout = Checkout.includes(:checkout_items => [:product => :user])
        .find_by(id: params[:checkout_id], checkout_type: :product)

      is_exists?(@checkout, 'checkout')
    end

    def set_checkout_junkyard
      if params[:checkout_type] && (params[:checkout_type].eql?('both') || params[:checkout_type].eql?('junkyard'))
        @checkout_junkyard = Checkout.includes(:checkout_items)
          .find_by(id: params[:checkout_junkyard_id], checkout_type: :junkyard)

        is_exists?(@checkout_junkyard, 'checkout junkyard')
      end
    end

    #
    # check if checkout or payment response is exists and set status to 404
    #
    def is_exists?(objects, object_value)
      unless objects
        @object = object_value.titleize
        render "api/v1/errors/404", status: 404
      end
    end

    def create_product(products, product_ids)
      checkout = @user.checkouts.create(checkout_type: :product)

      products.each do |product|
        checkout.checkout_items.create(
          product_id: product.id,
          deposit: product.deposit,
          item_type: :product
        ) if product.available?
      end

      @user.carts.where("product_id IN (?)", product_ids.split(",")).delete_all # delete selected items from cart
      checkout.id
    end

    def create_junkyard(junkyard_products, junkyard_ids)
      checkout = @user.checkouts.create(checkout_type: :junkyard)

      junkyard_products.each do |junkyard_product|
        checkout.checkout_items.create(product_id: junkyard_product.id, item_type: :junkyard) if junkyard_product.available?
      end

      @user.carts.where("product_id IN (?) ", junkyard_ids.split(",")).delete_all # delete selected items from cart
      checkout.id
    end

    def create_rent_histories_junkyard(checkout_junkyard)
      checkout_junkyard.checkout_items.each do |checkout_item|
        renter_id = checkout_junkyard.user_id
        product_id = checkout_item.product_id

        rent_history = RentHistory.create(
          renter_id: renter_id,
          product_id: product_id,
          rent_type: :junkyard,
          status: 201
        )

        rent_history.junkyard_product.update(aasm_state: :not_available) if rent_history
      end
    end
end
