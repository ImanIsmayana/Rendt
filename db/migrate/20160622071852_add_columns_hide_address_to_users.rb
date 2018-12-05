class AddColumnsHideAddressToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hide_address, :boolean, default: false
  end
end
