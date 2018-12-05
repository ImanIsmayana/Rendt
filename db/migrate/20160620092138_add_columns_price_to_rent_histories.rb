class AddColumnsPriceToRentHistories < ActiveRecord::Migration
  def change
    add_column :rent_histories, :price, :decimal
  end
end
