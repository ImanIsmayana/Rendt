node(:error){ @error }
node(:errors){ @errors }
child @product do
  attributes :id, :name, :one_hour, :four_hours, :one_day, :one_week, :deposit, :aasm_state, :description, 
    :location, :latitude, :longitude, :created_at

  #child(:checkout_items, object_root: false) do
  #  attributes :end_time
  #end

  child(:category) do
    attributes :id, :name
  end

  child(:user) do
    attributes :id
    node(:name){|user| user.full_name}
  end

  node(:created_at){|product| product.created_at.strftime("%B %d, %Y")}

  node(:attachments) do |product|
    attachments = []
    product.attachments.each do |attachment|
      attachments.push(attachment.name.url)
    end
    attachments
  end

  node :is_owner do |product|
    product.user == @user
  end

  node :is_liked do |product|
    @user.liked? product rescue false
  end

  node :is_favourited do |product|
    product.favourited_by?(@user)
  end

  node :likes_count do |product|
    product.get_likes.size
  end

  node(:countdown) { @product.countdown }
end