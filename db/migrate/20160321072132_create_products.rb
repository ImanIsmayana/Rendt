class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :category_id
      t.decimal :price
      t.text :description
      t.string :location
      t.text :special_condition
      t.decimal :deposit
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :products, :category_id
    add_index :products, :user_id
  end
end
