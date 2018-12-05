class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.integer :user_id
      t.integer :product_id

      t.timestamps null: false
    end
    add_index :carts, :user_id
    add_index :carts, :product_id
  end
end
