class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :quality, default: 0
      t.integer :price, default: 0
      t.integer :deposit, default: 0
      t.integer :service, default: 0
      t.integer :tool_safely, default: 0
      t.integer :return_on_time, default: 0
      t.integer :return_in_good_and_clean, default: 0
      t.integer :overall_rating, default: 0
      t.text :comment
      t.integer :user_id
      t.integer :target_id
      t.string :target_type

      t.timestamps null: false
    end
    add_index :reviews, :user_id
    add_index :reviews, :target_id
  end
end
