class CreateJunkyardProducts < ActiveRecord::Migration
  def change
    create_table :junkyard_products do |t|
      t.string :name
      t.text :description
      t.string :location
      t.text :special_condition
      t.string :size
      t.string :latitude
      t.string :longitude
      t.string :aasm_state
      t.references :category, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      
      t.timestamps null: false
    end
  end
end
