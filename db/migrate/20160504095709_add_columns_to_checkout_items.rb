class AddColumnsToCheckoutItems < ActiveRecord::Migration
  def change
    add_column :checkout_items, :start_time, :timestamp, default: Time.now
    add_column :checkout_items, :end_time, :timestamp
    add_column :checkout_items, :reminder_time, :timestamp
  end
end
