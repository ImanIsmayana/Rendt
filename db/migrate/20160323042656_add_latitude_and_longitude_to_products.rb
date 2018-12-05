class AddLatitudeAndLongitudeToProducts < ActiveRecord::Migration
  def change
    add_column :products, :latitude, :string
    add_column :products, :longitude, :string
  end
end
