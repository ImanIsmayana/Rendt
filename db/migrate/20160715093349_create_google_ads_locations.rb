class CreateGoogleAdsLocations < ActiveRecord::Migration
  def change
    create_table :google_ads_locations do |t|
      t.string :name
      t.integer :width
      t.string :location
      t.integer :number
      t.string :status
      t.integer :sort_order

      t.timestamps null: false
    end
  end
end
