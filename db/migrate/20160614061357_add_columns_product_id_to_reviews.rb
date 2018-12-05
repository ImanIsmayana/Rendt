class AddColumnsProductIdToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :product_id, :integer
    add_index :reviews, :product_id
  end
end
