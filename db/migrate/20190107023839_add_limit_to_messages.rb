class AddLimitToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :limit, :string
  end
end
