class CreateTransferRequests < ActiveRecord::Migration
  def change
    create_table :transfer_requests do |t|
      t.decimal :requested_amount
      t.string :aasm_state
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
