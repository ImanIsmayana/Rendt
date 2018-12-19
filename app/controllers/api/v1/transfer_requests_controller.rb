class Api::V1::TransferRequestsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication
  before_action :set_activity, only: :all

  respond_to :json

  api :POST, "/v1/transfer_requests/create", "Get list of all notifications of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User which has notifications", required: true
  param :requested_amount, String, desc: "Amount", required: true
  description "Get list of all notifications details of current user"

  def create
    request_params = transfer_request_params.merge(user_id: @user.id)
    transfer_request = TransferRequest.new(request_params)

    if transfer_request.save
      @transfer_request = transfer_request
      render json: {status: 201}
    else
      @error = 1
      @errors = transfer_request.errors
      render json: {status: 422}
    end
  end

  private
    def transfer_request_params
      params.except!(:authentication_token).permit(:id, :requested_amount, :status, :user_id)
    end
end
