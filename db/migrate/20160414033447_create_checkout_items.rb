class CreateCheckoutItems < ActiveRecord::Migration
  def change
    create_table :checkout_items do |t|
      t.integer :product_id
      t.integer :checkout_id
      t.decimal :price
      t.string :rent_time
      t.decimal :total_price

      t.timestamps null: false
    end
    add_index :checkout_items, :product_id
    add_index :checkout_items, :checkout_id
  end
end
