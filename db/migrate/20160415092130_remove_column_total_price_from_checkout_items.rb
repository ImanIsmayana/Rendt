class RemoveColumnTotalPriceFromCheckoutItems < ActiveRecord::Migration
  def down
    add_column :checkout_items, :total_price, :decimal
  end
end
