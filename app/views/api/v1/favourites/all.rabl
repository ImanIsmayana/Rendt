if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }
end
child @favourites.includes(:favouritable => :category), object_root: false do
  child :favouritable do |f|
    attributes :id, :name, :one_hour, :four_hours, :one_day, :one_week, :deposit, :aasm_state, :description

    node :attachment do |product|
      product.attachments.first.name.url rescue nil
    end

    node :category_name do |product|
      product.category.name
    end

    node :is_liked do |product|
      current_user.liked? product rescue false
    end

    node :is_favourited do |product|
      product.favourited_by?(@user)
    end
  end
end