class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :check_maintenance_mode
  before_action :set_page_menus

  private
    def check_maintenance_mode
      @setting = SystemSetting.cached

      if @setting.try(:maintenance_mode?)
        @maintenance_message = @setting.try(:maintenance_message)
        render "maintenance/index"
      end
    end

    def set_page_menus
      @top_menus = Page.cached_top_menus
      @bottom_menus = Page.cached_bottom_menus
    end
end
