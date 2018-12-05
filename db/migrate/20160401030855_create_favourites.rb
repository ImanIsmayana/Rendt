class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.integer :user_id
      t.integer :favouritable_id
      t.string :favouritable_type

      t.timestamps null: false
    end
    add_index :favourites, :user_id
    add_index :favourites, :favouritable_id
  end
end
