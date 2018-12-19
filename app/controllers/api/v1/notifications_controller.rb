class Api::V1::NotificationsController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication
  before_action :set_activity, only: :all

  respond_to :json

  api :GET, "/v1/notifications/all", "Get list of all notifications of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User which has notifications", required: true
  param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all notifications details of current user"

  def all
    @notifications = PublicActivity::Activity.get_notifications(@recipient_id).page(params[:page]).per(15)
    render json: {status: 200}
  end

  api :POST, "/v1/notifications/test_notify", "Testing notification"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User which has notifications", required: true
  param :recipient_id, String, desc: "Recipient ID", required: true
  param :type, String, desc: "Tyep of notification like as
    (accepted_refund, give_refund, favourite_product, favourite_lender, favourite_junkyard_product)", required: true
  param :title, String, desc: "Title of message"
  param :message, String, desc: "Message"
  param :product_id, String, desc: "Product ID"
  param :product_name, String, desc: "Product Name"

  def test_notify
    recipient = User.find_by(id: params[:recipient_id])

    activity = PublicActivity::Activity.new

    response_notif = activity.create_notification(
      key: 'refund.accepted_by_renter',
      owner: @user,
      recipient: recipient,
      notification_type: params[:type],
      title_message: params[:title],
      body_message: params[:message],
      another_parameters: {
        product_id: params[:product_id],
        product_name: params[:product_name]
      },
      status: 201
    )

    render json: response_notif, status: 200
  end

  private
    def set_activity
      @recipient_id, current_state, new_state = [@user.id, 'unread', 'read']
      PublicActivity::Activity.update_state_to_read(@recipient_id, current_state, new_state)
    end
end
