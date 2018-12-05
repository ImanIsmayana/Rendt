ActiveAdmin.register Home do

	permit_params :title, :app_description, :google_play_url, :features_one_title, :features_one_description, :features_two_title, :features_two_description, :features_three_title, :features_three_description, :features_four_title, :features_four_description, :application_information_title, :application_information_description

end
