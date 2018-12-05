class AddAddressAndShippingAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address, :text
    add_column :users, :shipping_address, :text
  end
end
