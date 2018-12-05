class AddColumnCheckoutTypeToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :checkout_type, :string
  end
end
