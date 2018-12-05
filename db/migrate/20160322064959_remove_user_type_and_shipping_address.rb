class RemoveUserTypeAndShippingAddress < ActiveRecord::Migration
  def change
    remove_column :users, :user_type
    remove_column :users, :shipping_address
  end
end
