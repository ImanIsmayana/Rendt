class Api::V1::ReviewsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  # skip_before_action :verify_authenticity_token
  before_action :check_user_authentication
  before_action :set_review, only: [:detail, :update_lender_review, :update_renter_review, :delete]

  respond_to :json

  api :GET, "/v1/reviews/lender/all", "Get list of all reviews for lender"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all reviews for lender"

  def get_lender_all
    @reviews = Review.includes(:user, :target).where(target_type: 'lender', target_id: @user.id)
      .page(params[:page]).per(10)
    render json: {status: 200}
  end

  api :GET, "/v1/reviews/renter/all", "Get list of all reviews for lender"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all reviews for lender"

  def get_renter_all
    @reviews = Review.includes(:user, :target).where(target_type: 'renter', target_id: @user.id)
      .page(params[:page]).per(10)
    render json: {status: 200}
  end

  api :GET, "/v1/reviews/list", "Get list of all user reviews for other user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :target_id, String, desc: "Target ID", required: true
  description "Get list of all user reviews for other user"

  def list_all
    @reviews = Review.includes(:user, :target).where(target_id: params[:target_id], target_type: 'lender')
    render json: {status: 200}
  end

  api :GET, "/v1/reviews/detail", "Show review detail"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :review_id, String, desc: "Review ID to get its detail", required: true
  description "Get detail data review"

  # OPTIMIZE we can retrieve review from @user.reviews (done) and I'm used action controller
  def detail
    @review = @current_review
    @review.update_attributes(aasm_state: :read)
    render json: {status: 200}
  end

  api :POST, "/v1/reviews/lender/create", "Create review for Lender or Product owner"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :target_id, String, desc: "User ID of Lender", required: true
  param :product_id, String, desc: "Product ID"
  param :quality, String, desc: "Number of value for quality of the product (1-5)", required: true
  param :price, String, desc: "Number of value for price of the product (1-5)", required: true
  param :deposit, String, desc: "Number of value for deposit of the product (1-5)", required: true
  param :service, String, desc: "Number of value for service of the product (1-5)", required: true
  param :overall_rating, String, desc: "Number of value for overall_rating of the product (1-5)", required: true
  param :comment, String, desc: "Comment about the Lender", required: true
  description "Create review for Lender or Product owner from Renter"

  # OPTIMIZE create private methods to store the parameter and it's better if we can use strong parameter (done)
  def post_lender_review
    review = @user.reviews.build review_params.merge(target_type: 'lender')

    if review.save
      @review = review

      title_message = 'Review'
      body_message = "You have already reviewed by #{@user.full_name}"
      send_notif('create_for_lender', 'review_for_lender', title_message, body_message, @review.target)
      render json: {status: 201}
    else
      @errors = review.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/reviews/lender/update", "Update review for Lender or Product owner"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :review_id, String, desc: "Review ID to be updated", required: true
  param :product_id, String, desc: "Product ID"
  param :quality, String, desc: "Number of value for quality of the product (1-5)", required: true
  param :price, String, desc: "Number of value for price of the product (1-5)", required: true
  param :deposit, String, desc: "Number of value for deposit of the product (1-5)", required: true
  param :service, String, desc: "Number of value for service of the product (1-5)", required: true
  param :overall_rating, String, desc: "Number of value for overall_rating of the product (1-5)", required: true
  param :comment, String, desc: "Comment about the Lender", required: true
  description "Update review for Lender or Product owner from Renter"

  # OPTIMIZE use same private method as post_lender_review API (done)
  def update_lender_review
    if @current_review.update review_params
      @review = @current_review

      title_message = 'Review'
      body_message = "#{@user.full_name} has updated review"
      send_notif('updated_for_lender', 'updated_review_for_lender', title_message, body_message, @review.target)
      render json: {status: 200}
    else
      @errors = @current_review.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/reviews/renter/create", "Create review for Renter"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :target_id, String, desc: "User ID of Renter", required: true
  param :product_id, String, desc: "Product ID"
  param :tool_safely, String, desc: "Number of value for quality of the product (1-5)", required: true
  param :return_on_time, String, desc: "Number of value for price of the product (1-5)", required: true
  param :return_in_good_and_clean, String, desc: "Number of value for deposit of the product (1-5)", required: true
  param :overall_rating, String, desc: "Number of value for overall_rating of the product (1-5)", required: true
  param :comment, String, desc: "Comment about the Lender", required: true
  description "Create review for Renter from Lender"

  # OPTIMIZE create private methods for params and use strong parameter (done)
  def post_renter_review
    review = @user.reviews.build review_params.merge(target_type: 'renter')

    if review.save
      @review = review

      title_message = 'Review'
      body_message = "You have already reviewed by #{@user.full_name}"
      send_notif('create_for_renter', 'review_for_renter', title_message, body_message, @review.target)
      render json: {status: 201}
    else
      @errors = review.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/reviews/renter/update", "Update review for Renter"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :review_id, String, desc: "Review ID to be updated", required: true
  param :product_id, String, desc: "Product ID"
  param :tool_safely, String, desc: "Number of value for quality of the product (1-5)", required: true
  param :return_on_time, String, desc: "Number of value for price of the product (1-5)", required: true
  param :return_in_good_and_clean, String, desc: "Number of value for deposit of the product (1-5)", required: true
  param :overall_rating, String, desc: "Number of value for overall_rating of the product (1-5)", required: true
  param :comment, String, desc: "Comment about the Lender", required: true
  description "Update review for Renter from Lender"

  # OPTIMIZE we can use same private method as post_renter_review API (done)
  def update_renter_review
    if @current_review.update review_params
      @review = @current_review

      title_message = 'Review'
      body_message = "#{@user.full_name} has updated review"
      send_notif('updated_for_renter', 'updated_review_for_render', title_message, body_message, @review.target)
      render json: {status: 200}
    else
      @errors = @current_review.errors
      render json: {status: 422}
    end
  end

  api :POST, "/v1/reviews/delete", "Delete review for both Lender and Renter"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :review_id, String, desc: "Review ID to be deleted", required: true
  description "Delete review for both Lender and Renter"

  # OPTIMIZE retrieve review from @user.reviews to make it shorter (done) and I'm used action controller
  def delete
    @current_review.destroy
    render json: {status: 200}
  end

  private
    def set_review
      @current_review = Review.find_by(id: params[:review_id])

      unless @current_review
        @object = "Review"
        render "api/v1/errors/404", status: 404
      end
    end

    def send_notif(key, type, title_message, body_message, recipient)
      activity = PublicActivity::Activity.new

      #
      # create activity includes send notification to mobile
      #
      response_notif = activity.create_notification(
        key: "reviews.#{key}",
        owner: @user,
        recipient: recipient,
        notification_type: "#{type}",
        title_message: title_message,
        body_message: body_message,
        another_parameters: {
          recipient_id: recipient.id,
          recipient_name: recipient.full_name
        },
        status: 201
      )

      if response_notif[:error]
        @object = response_notif[:object]
        render "api/v1/errors/404", status: 404
      end
    end

    def review_params
      params.except!(:authentication_token).permit(:review_id, :target_id, :product_id, :quality, :price, :deposit, :service, :overall_rating,
      :comment, :target_type, :tool_safely, :return_on_time, :return_in_good_and_clean)
    end
end
