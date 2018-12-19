node(:error){ @error }
node(:errors){ @errors }
child @products do
  attributes :id, :name, :one_hour, :four_hours, :one_day, :one_week, :deposit, :aasm_state, :descriptionl, :latitude, :longitude, :location

  node :attachment do |product|
    product.attachments.first.name.url if product.attachments.present?
  end

  node :image_url do |image|
    ENV['RENDT'] + image.image_url
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

  node do |product|
    if product.rent_histories.active.present?
      node(:renter_id) { product.rent_histories.active.last.renter_id }
      node(:rented_by) { product.rent_histories.active.last.renter.full_name }
    else
      node(:renter_id) { nil }
      node(:rented_by) { nil }
    end
  end
  node(:status){ 200 }
end