if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
#node(:category_name){ @category.name }
if @error.eql? 0
  node(:status){ 200 }

  child @products do
    attributes :id, :name, :one_hour, :four_hours, :one_day, :one_week, :deposit, :aasm_state, :description,
      :rent_status

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

    node do |product|
      if product.rent_histories.active.present?
        node(:renter_id) { product.rent_histories.active.last.renter_id }
        node(:rented_by) { product.rent_histories.active.last.renter.full_name }
      else
        node(:renter_id) { nil }
        node(:rented_by) { nil }
      end
    end
  end
end