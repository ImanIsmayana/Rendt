if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 201 }
  child @junkyard_product do
    attributes :id, :name, :description, :special_condition,
               :location, :latitude, :longitude, :size, :category_id, :user_id, :aasm_state
  end
end