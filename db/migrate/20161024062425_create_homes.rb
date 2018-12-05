class CreateHomes < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.string :title
      t.string :app_description
      t.string :google_play_url
      t.string :features_one_title
      t.string :features_one_description
      t.string :features_two_title
      t.string :features_two_description
      t.string :features_three_title
      t.string :features_three_description
      t.string :features_four_title
      t.string :features_four_description
      t.string :application_information_title
      t.string :application_information_description

      t.timestamps null: false
    end
  end
end
