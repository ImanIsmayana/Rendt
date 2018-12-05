class HomeController < ApplicationController
	layout "landing"
  def index
    # @pages = Page.first_three
    @home = Home.first
  end

  private

  def home_params
    params.require(:home).permit(:title, :app_description, :google_play_url, :features_one_title, :features_one_description, :features_two_title, :features_two_description, :features_three_title, :features_three_description, :features_four_title, :features_four_description, :application_information_title, :application_information_description)
  end
end
