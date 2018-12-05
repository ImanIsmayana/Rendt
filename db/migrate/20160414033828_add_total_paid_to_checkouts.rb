class AddTotalPaidToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :total_paid, :decimal
  end
end
