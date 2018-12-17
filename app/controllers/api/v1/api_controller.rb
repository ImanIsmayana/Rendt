class Api::V1::ApiController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # OPTIMIZE see description above, for API we can use :null_session rather than :exception
  protect_from_forgery with: :exception

  # OPTIMIZE once we use :null_session no need to skip verify_authenticity_token and please remove all skip verify_authenticity_token for all API controller
  skip_before_action :verify_authenticity_token
  skip_before_action :set_page_menus
  before_action :error_init
  before_action :check_maintenance_mode
  respond_to :json

  # OPTIMIZE we could remove this action and put the content under check_user_authentication method
  def set_user_by_authentication_token
    @user = User.find_by_authentication_token(params[:authentication_token])
  end

  def check_user_authentication
    set_user_by_authentication_token

    if @user.blank?
      render "api/v1/errors/401", status: 401
    end
  end

  private
    #
    # set default of error variables status
    #
    def check_maintenance_mode
      setting = SystemSetting.cached

      if setting.try(:maintenance_mode?)
        render json: { errorType: 'maintenance', statusText: setting.maintenance_message }, status: 503
      end
    end

    def error_init
      @error = 0
      @errors = ""
    end

end
