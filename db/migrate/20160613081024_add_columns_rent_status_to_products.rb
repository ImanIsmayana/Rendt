class AddColumnsRentStatusToProducts < ActiveRecord::Migration
  def change
    add_column :products, :rent_status, :string
  end
end
