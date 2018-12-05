class AddColumnsFavouritesCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :favourites_count, :integer, default: 0
  end
end
