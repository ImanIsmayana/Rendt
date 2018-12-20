if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

  child @junkyard_product do
    attributes :id, :name, :description, :special_condition, :location, :latitude, :longitude, :size, :category_id, :aasm_state

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

  end
end