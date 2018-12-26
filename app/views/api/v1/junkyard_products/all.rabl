if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

  child @junk_yard_products do
    attributes :id, :name, :description, :special_condition, :location, :latitude,
               :longitude, :size, :category_id, :aasm_state

    node :attachment do |product|
      product.attachments.first.name.url rescue nil
    end

    node :category_name do |product|
      product.category.name
    end

    node :is_liked do |product|
      @user.liked? product rescue false
    end

    node :is_favourited do |product|
      product.favourited_by?(@user)
    end
  end
end