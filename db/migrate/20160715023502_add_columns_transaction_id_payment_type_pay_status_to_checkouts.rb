class AddColumnsTransactionIdPaymentTypePayStatusToCheckouts < ActiveRecord::Migration
  def change
    add_column :checkouts, :transaction_id, :string
    add_column :checkouts, :payment_type, :string
    add_column :checkouts, :pay_status, :string
  end
end
