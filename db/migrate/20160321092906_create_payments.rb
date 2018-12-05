class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :paypal_email
      t.integer :user_id

      t.timestamps null: false
    end
    add_index :payments, :user_id
  end
end
