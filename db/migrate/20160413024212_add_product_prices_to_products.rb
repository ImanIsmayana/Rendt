class AddProductPricesToProducts < ActiveRecord::Migration
  def change
    remove_column :products, :price, :decimal
    add_column :products, :one_hour, :decimal, default: 0
    add_column :products, :four_hours, :decimal, default: 0
    add_column :products, :one_day, :decimal, default: 0
    add_column :products, :one_week, :decimal, default: 0
  end
end
