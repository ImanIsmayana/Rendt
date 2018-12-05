class CreateMobilePlatforms < ActiveRecord::Migration
  def change
    create_table :mobile_platforms do |t|
      t.string :device_id
      t.string :device_model
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
