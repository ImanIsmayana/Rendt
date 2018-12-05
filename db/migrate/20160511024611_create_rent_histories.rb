class CreateRentHistories < ActiveRecord::Migration
  def change
    create_table :rent_histories do |t|
      t.integer :renter_id
      t.integer :lender_id
      t.string :rent_time
      t.string :aasm_state
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
