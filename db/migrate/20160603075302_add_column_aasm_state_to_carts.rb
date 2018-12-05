class AddColumnAasmStateToCarts < ActiveRecord::Migration
  def change
    add_column :carts, :aasm_state, :string
  end
end
