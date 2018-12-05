class CreateSystemSettings < ActiveRecord::Migration
  def change
    create_table :system_settings do |t|
      t.string :name
      t.string :logo
      t.string :email_sender
      t.integer :listing_per_page
      t.boolean :maintenance_mode
      t.text :maintenance_message

      t.timestamps null: false
    end
  end
end
