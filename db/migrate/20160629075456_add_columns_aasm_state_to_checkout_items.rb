class AddColumnsAasmStateToCheckoutItems < ActiveRecord::Migration
  def change
    add_column :checkout_items, :aasm_state, :string
  end
end
