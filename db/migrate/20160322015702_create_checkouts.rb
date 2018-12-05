class CreateCheckouts < ActiveRecord::Migration
  def change
    create_table :checkouts do |t|
      t.integer :lend_id
      t.integer :payment_id
      t.string :status, default: "pending"

      t.timestamps null: false
    end
    add_index :checkouts, :lend_id
    add_index :checkouts, :payment_id
  end
end
