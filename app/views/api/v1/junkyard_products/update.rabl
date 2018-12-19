node(:error){ @error }
node(:errors){ @errors }
child @junkyard_product do
  attributes :id, :name, :description, :special_condition, :location, :latitude, :longitude, :size, :category_id, :user_id, :aasm_state
  node(:status){ 200 }
end