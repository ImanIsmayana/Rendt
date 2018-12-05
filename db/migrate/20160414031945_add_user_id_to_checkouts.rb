class AddUserIdToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :user_id, :integer
    add_index :checkouts, :user_id
  end
end
