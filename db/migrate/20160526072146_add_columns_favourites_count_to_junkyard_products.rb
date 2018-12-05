class AddColumnsFavouritesCountToJunkyardProducts < ActiveRecord::Migration
  def change
    add_column :junkyard_products, :favourites_count, :integer, default: 0
  end
end
