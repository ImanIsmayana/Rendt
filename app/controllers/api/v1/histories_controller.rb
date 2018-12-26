class Api::V1::HistoriesController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  before_action :check_user_authentication
  before_action :set_history_by_product, only: :update_status

  respond_to :json

  api :GET, "/v1/histories/my_transaction", "Get list of all transaction history of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all transaction history of current user"

  def my_transaction
    my_order_hash = RentHistory.get_my_order_hash(@user.id, params[:page], false)
  end

  api :GET, "/v1/histories/my_order", "Get list of all order tools history of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all order tools history of current user"

  def my_order
    my_order_hash = RentHistory.get_my_order_hash(@user.id, params[:page])
  end

  api :GET, "/v1/histories/my_wallet", "Get list of all total amount"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  description "Get list of all total amount from rent items and lend items"

  def my_wallet
    @total_spend =  RentHistory.total_spend(@user.id)
    @total_income = RentHistory.total_income(@user.id)
    transfer_request = TransferRequest.where(user_id: @user.id, aasm_state: :pending)
    @is_transfer_request = transfer_request.present? ? true : false
  end

  api :GET, "/v1/histories/update_status", "Update status item in rent histories"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User who will favourite a product", required: true
  param :product_id, String, desc: "Product ID", required: true
  param :status, String, desc: "Status Rent of item or product('rented' or 'returned')", required: true
  description "Update status item in rent histories"

  def update_status
    @rent_history.aasm_state = params[:status]

    if @rent_history.save
      @status = @rent_history.aasm_state
    else
      @error = 1
      @errors = @rent_history.errors
    end
  end

  private
    def set_history_by_product
      @rent_history = RentHistory.find_by(product_id: params[:product_id], renter_id: @user.id, rent_type: 'product')

      unless @rent_history
        @object = "Rent History"
        render "api/v1/errors/404", status: 404
      end
    end
end
