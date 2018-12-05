class AddColumnPayKeyToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :pay_key, :string
  end
end
