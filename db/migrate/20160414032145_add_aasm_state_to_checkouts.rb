class AddAasmStateToCheckouts < ActiveRecord::Migration
  def change
    remove_column :checkouts, :status, :string
    add_column :checkouts, :aasm_state, :string
  end
end
