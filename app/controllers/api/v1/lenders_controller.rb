class Api::V1::LendersController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication

  respond_to :json

  api :GET, "/v1/lenders/all", "Get list of all lenders"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all lenders"

  def all
    @lenders = User.get_lender_have_products.page(params[:page]).per(10)
  end

  api :GET, "/v1/lenders/profile", "Get of lender profile"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :user_id, String, desc: "User ID to show lender profile", required: true
  description "Get of lender profile"

  def profile
    @lender = User.get_profile(params[:user_id])
    @review_count = Review.where(target_id: @lender.id, target_type: 'lender').size

    if @lender
      if @lender.products.blank?
        @object = "products"
        render "api/v1/errors/404", status: 404
      end
    else
      @object = "Lender"
      render "api/v1/errors/404", status: 404
    end

  end
end