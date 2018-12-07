ActiveAdmin.register Home do

  permit_params :title, :app_description, :google_play_url, :features_one_title, :features_one_description, :features_two_title, :features_two_description, :features_three_title, :features_three_description, :features_four_title, :features_four_description, :application_information_title, :application_information_description

  index do
    selectable_column
    id_column
    column :title
    column :app_description
    column :created_at
    actions
  end

  filter :title
  filter :app_description

  form do |f|
    f.inputs "Admin Details" do
      f.input :title
      f.input :app_description
      f.input :google_play_url
      f.input :features_one_title
      f.input :features_one_description
      f.input :features_two_title
      f.input :features_two_description
      f.input :features_three_title
      f.input :features_three_description
      f.input :features_four_title
      f.input :features_four_description
      f.input :application_information_title
      f.input :application_information_description
    end
    f.actions
  end
end
