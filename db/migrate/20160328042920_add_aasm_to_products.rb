class AddAasmToProducts < ActiveRecord::Migration
  def change
    add_column :products, :aasm_state, :string
  end
end
