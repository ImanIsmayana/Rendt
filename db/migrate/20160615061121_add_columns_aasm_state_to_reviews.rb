class AddColumnsAasmStateToReviews < ActiveRecord::Migration
  def change
    add_column :reviews, :aasm_state, :string
  end
end
