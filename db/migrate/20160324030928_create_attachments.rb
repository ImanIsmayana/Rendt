class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.integer :attachable_id
      t.string :attachable_type

      t.timestamps null: false
    end
    add_index :attachments, :attachable_id
  end
end
