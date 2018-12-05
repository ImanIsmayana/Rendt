class AddDocumentableToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :documentable_id, :integer
    add_column :messages, :documentable_type, :string
    add_index :messages, :documentable_id
  end
end
