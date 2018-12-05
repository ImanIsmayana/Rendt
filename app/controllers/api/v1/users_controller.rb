class Api::V1::UsersController < Api::V1::ApiController
  resource_description do
    api_versions "1.0"
  end

  skip_before_action :verify_authenticity_token
  before_action :check_user_authentication, only: [:profile, :hide_address, :logout, :update, :update_password, 
    :upload_photo, :delete_photo]

  respond_to :json

  api :POST, "/v1/users/register", "Register Process"
  formats ['json']
  param :first_name, String, desc: "User First Name - Length 3..30 characters", required: true
  param :last_name, String, desc: "User Last Name - Length 3..30 characters", required: true
  param :email, String, desc: "User Email", required: true
  param :password, String, desc: "User Password", required: true
  param :address, String, desc: "User Address / Desired meet up location", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :device_id, String, desc: "Device ID from used platform user"
  param :device_model, String, desc: "Device Model from used platform user"
  description "User register process - will return status success or error and send link for verification to email"

  # OPTIMIZE create private params method and use strong parameter (done)
  def register
    user = User.new(user_params.except!(:device_id, :device_model))
    user.build_mobile_platform(device_id: user_params[:device_id], device_model: user_params[:device_model])
    
    if user.save
      @user = user
    else
      @error = 1
      @errors = user.errors
    end
  end

  api :POST, "/v1/users/login", "Login Process"
  formats ['json']
  param :email, String, desc: "User Email", required: true
  param :password, String, desc: "User Password", required: true
  param :device_id, String, desc: "Device ID from used platform user"
  param :device_model, String, desc: "Device Model from used platform user"
  description "User login process - will return auth token if login process has succeeded."

  def login
    user = User.find_by_email(params[:email])

    if user.blank?
      @error = 1
      @errors = { email: ["User with email #{params[:email]} is not registered!"] }
    else
      # if user.confirmed?
        if user.is_blocked
          @error = 1
          @errors = { authentication: ["Your account already blocked. Please contact admin for further information"] }
        else
          if user.valid_password? params[:password]
            warden.set_user(user)
            mobile_platform = user.mobile_platform || user.build_mobile_platform
            mobile_platform.update_attributes(device_id: params[:device_id], device_model: params[:device_model])
            @authentication_token = user.authentication_token
            @user_id = user.id
            @user = user
          else
            @error = 1
            @errors = { authentication: ["Invalid email and password"] }
          end
        end
      # else
      #   @error = 1
      #   @errors = { authentication: ["Your e-mail address has not been verified"] }
      # end
    end
  end

  api :POST, "/v1/users/logout", "Logout Process"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User", required: true
  description "User logout process - will destroy current authentication token and generate new token automatically"

  # OPTIMIZE no need to check @user, it's done by check_user_authentication
  def logout
    if @user
      # automatically regenerate new token handle by simple_token_authentication
      @user.update(authentication_token: nil)
    end
  end

  api :POST, "/v1/users/forgot_password", "Request for reset password"
  formats ['json']
  param :email, String, desc: "User Email", required: true
  description "User reset password - will send email reset password instruction."

  # OPTIMIZE not sure this line "yield send_forgot_password_email if block_given?" needed
  # we can use unless to detect error (done)
  def forgot_password
    if params[:email].blank?
      @error = 1
      @errors = {email: ["Email cannot be blank!"]}
    else
      user = User.where(email: params[:email])

      if user.blank?
        @error = 1
        @errors = {email: ["User with email #{params[:email]} is not registered!"]}
      else
        send_forgot_password_email = User.send_reset_password_instructions(email: params[:email])
        yield send_forgot_password_email if block_given?

        unless successfully_sent?(send_forgot_password_email)
          @error = 1
          @errors = {email: ["An error occured when sending email!"]}
        end
      end
    end
  end

  api :POST, "/v1/users/resend_confirmation", "Request resend email confirmation"
  formats ['json']
  param :email, String, desc: "User Email", required: true
  description "User request to resend email confirmation."

  # OPTIMIZE use unless for detecting error (done)
  def resend_confirmation
    if params[:email].blank?
      @error = 1
      @errors = {email: ["Email cannot be blank!"]}
    else
      user = User.where(email: params[:email])
      if user.blank?
        @error = 1
        @errors = {email: ["User with email #{params[:email]} is not registered!"]}
      else
        send_confirmation_email = user.first.send_confirmation_instructions

        unless successfully_sent?(send_confirmation_email)
          @error = 1
          @errors = {email: ["An error occured when sending email!"]}
        end
      end
    end
  end

  api :GET, "/v1/users/profile", "Get profile of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  description "Get profile information of current user"

  def profile
    @profile = @user
  end

  api :POST, "/v1/users/hide_address", "Ability for show or hide address user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :hide, ['t', 'f'], desc: "Hide address to (t = true, or f = false)", required: true
  description "Ability for show or hide address user"

  def hide_address
    unless @user.update_attributes(hide_address: params[:hide])
      @error = 1
      @errors = @user.errors
    end
  end

  api :POST, "/v1/users/update", "Update profile of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :first_name, String, desc: "User First Name - Length 3..30 characters", required: true
  param :last_name, String, desc: "User Last Name - Length 3..30 characters", required: true
  param :email, String, desc: "User Email", required: true
  param :password, String, desc: "User Password", required: true
  param :address, String, desc: "User Address / Desired meet up location", required: true
  param :phone_number, String, desc: "User Phone Number", required: true
  param :latitude, String, desc: "User Latitude", required: true
  param :longitude, String, desc: "User Longitude", required: true
  param :description, String, desc: "Description about their business"
  description "User update process - will return status success or error"

  def update
    current_user = @user

    if current_user.update_attributes(user_params)
      @current_user = current_user
    else
      @error = 1
      @errors = current_user.errors
    end
  end

  api :POST, "/v1/users/upload_photo", "Upload photo profile user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  description "Upload photo profile user [Important : Add parameter called 'name' for file upload]"

  def upload_photo
    photo = @user.attachment || @user.build_attachment
    photo.name = user_params[:name]

    if photo.save
      @photo = photo
    else
      @error = 1
      @errors = photo.errors
    end
  end

  api :POST, "/v1/users/update_password", "Update password of current user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  param :current_password, String, desc: "User old password", required: true
  param :password, String, desc: "User new password", required: true
  param :password_confirmation, String, desc: "User bew password confirmation", required: true
  description "User update process - will return status success or error"

  def update_password
    current_user = @user

    if current_user.update_with_password(user_params)
      @current_user = current_user
    else
      @error = 1
      @errors = current_user.errors
    end
  end

  api :GET, "/v1/users/delete_photo", "Delete photo profile user"
  formats ['json']
  param :authentication_token, String, desc: "Authentication token of User"
  description "Delete photo profile user "

  def delete_photo
    photo = @user.attachment

    if photo
      photo.remove_name!
      photo.destroy
      @photo = photo
    else
      @object = "Photo"
      render "api/v1/errors/404", status: 404
    end
  end

  def confirmed
    render text: 'Confirmation success you can login on Mobile App'
  end

  private
    def set_user_by_email
      @user = User.find_by_email(params[:email])
      
      if @user.blank?
        @object = "Email"
        render "api/v1/errors/404", status: 404
      end
    end

    def user_params
      params.permit(:authentication_token, :email, :current_password, :password, :password_confirmation, :first_name, :last_name, 
        :address, :longitude, :latitude, :phone_number, :name, :device_id, :device_model, :description)
    end

    #
    # function from devise to check whether email has successfully sent or not
    #
    def successfully_sent?(resource)
      notice = if Devise.paranoid
        resource.errors.clear
        :send_paranoid_instructions
      elsif resource.errors.empty?
        :send_instructions
      end

      if notice.eql? :send_instructions
        true
      else
        false
      end
    end
end
