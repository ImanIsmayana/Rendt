class AddColumnRentTypeToRentHistories < ActiveRecord::Migration
  def change
    add_column :rent_histories, :rent_type, :string
  end
end
