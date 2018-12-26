class Api::V1::MessagesController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  before_action :check_user_authentication
  before_action :set_message, only: [:reply_message, :conversation]
  before_action :set_recipient, only: [:post_message]

  respond_to :json

  api :GET, "/v1/messages/all", "Get list of all messages from any user connected with current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  # param :page, String, desc: "Page number of listing - per 10 data", required: true
  description "Get list of all messages from any user connected with current user"

  def all
    @messages = @user.messages.includes(:sent_messageable, :received_messageable).conversations
  end

  api :GET, "/v1/messages/conversation", "Get list of all conversation based on current user from renter side"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :message_id, String, desc: "Message ID"

  def conversation
    message = CustomMessage.find(params[:message_id])

    if message
      @messages = message.conversation.includes(:sent_messageable, :received_messageable).ascending
    end
  end

  api :GET, "/v1/messages/conversation_by_receiver", "Get list of all conversation based on current user from renter side"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :receiver_id, String, desc: "receiver_id", required: true

  def conversation_by_receiver
    message = CustomMessage.get_conversation_by_receiver(@user.id, params[:receiver_id])

    if message
      @messages = message.conversation.includes(:sent_messageable, :received_messageable).ascending
    end
  end

  api :POST, "/v1/messages/post_message", "Ability for user to post messages to lender"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :recipient_id, String, desc: "User ID for recipient message",required: true
  param :message, String, desc: "Content of enquiries", required: true
  description "Ability for user to post messages to lender"

  def post_message
    @message = @user.send_message(@recipient, {
      body: params[:message]
    })

    activity = PublicActivity::Activity.new
    title_message = "New Message From #{@user.full_name}"
    body_message = params[:message]

    #
    # create activity includes send notification to mobile
    #
    activity.create_notification(
      key: 'message.post',
      owner: @user,
      recipient: @recipient,
      notification_type: 'post_message',
      title_message: title_message,
      body_message: body_message,
      another_parameters: {
        message_id: @message.id
      },
      status: 201
    )
  end

  api :POST, "/v1/messages/reply_message", "Ability for user to reply messages to lender"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  param :message_id, String, desc: "Message ID to be replied", required: true
  param :recipient_id, String, desc: "Recipient ID", required: true
  param :message, String, desc: "Content of enquiries", required: true
  description "Ability for user to reply enquiry of an item or product"

  def reply_message
    @message = @user.reply_to(@current_message, {
      body: params[:message]
    })

    activity = PublicActivity::Activity.new
    title_message = "New Message From #{@user.full_name}"
    body_message = params[:message]

    recipient = User.find_by(id: params[:recipient_id])

    #
    # create activity includes send notification to mobile
    #
    activity.create_notification(
      key: 'message.reply',
      owner: @user,
      recipient: recipient,
      notification_type: 'reply_message',
      title_message: title_message,
      body_message: body_message,
      another_parameters: {
        message_id: @message.id
      },
      status: 201
    )
  end

  private
    def set_recipient
      @recipient = User.find_by(id: params[:recipient_id])

      unless @recipient
        @object = "Recipient"
        render "api/v1/errors/404", status: 404
      end
    end

    def set_message
      @current_message = CustomMessage.find_by(id: params[:message_id])
    end
end