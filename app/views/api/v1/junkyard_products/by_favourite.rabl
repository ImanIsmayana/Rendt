node(:error){ @error }
node(:errors){ @errors }
node(:category_name){ @category.name }
child @junkyard_products do
  attributes :id, :name, :description, :special_condition, :location, :latitude, :longitude, :size, :category_id, :aasm_state

  node :attachment do |product|
    product.attachments.first.name.url if product.attachments.present?
  end

  node :category_name do |product|
    product.category.name
  end

  node :is_liked do |product|
    @user.liked? product rescue false
  end

  node do |product|
    if product.favourites_count > 0
      { :is_favourited => true }
    else
      { :is_favourited => false }
    end
  end
  node(:status){ 200 }
end