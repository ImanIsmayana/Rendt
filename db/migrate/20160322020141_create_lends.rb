class CreateLends < ActiveRecord::Migration
  def change
    create_table :lends do |t|
      t.integer :product_id
      t.integer :user_id
      t.datetime :start_date
      t.datetime :end_time

      t.timestamps null: false
    end
    add_index :lends, :product_id
    add_index :lends, :user_id
  end
end
