class AddColumnsCheckoutIdCheckoutItemIdToRentHistories < ActiveRecord::Migration
  def change
    add_reference :rent_histories, :checkout, index: true, foreign_key: true
    add_reference :rent_histories, :checkout_item, index: true, foreign_key: true
  end
end
