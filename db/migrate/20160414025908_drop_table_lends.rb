class DropTableLends < ActiveRecord::Migration
  def change
    drop_table :lends
    remove_column :checkouts, :lend_id
  end
end
