class AddColumnItemTypeToCheckoutItems < ActiveRecord::Migration
  def change
    add_column :checkout_items, :item_type, :string
  end
end
