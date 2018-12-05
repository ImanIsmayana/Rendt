class AddDepositToCheckoutItems < ActiveRecord::Migration
  def change
    add_column :checkout_items, :deposit, :decimal
  end
end
