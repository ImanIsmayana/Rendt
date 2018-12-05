class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string :heading
      t.string :slug
      t.string :url
      t.string :meta_title
      t.text :meta_description
      t.text :short_intro
      t.text :content
      t.string :banner
      t.string :menu_title
      t.string :menu_position
      t.integer :menu_sort_order
      t.boolean :active

      t.timestamps null: false
    end
    add_index :pages, :slug, unique: true
  end
end
