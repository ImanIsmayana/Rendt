node(:error){ @error }
node(:errors){ @errors }
child @reviews do
  attribute :id, :quality, :price, :deposit, :service, :return_in_good_and_clean, :overall_rating, :comment, :aasm_state

  child :user => :sender do
    attributes :id

    node :full_name do |sender|
      sender.full_name
    end
  end

  child :target => :receiver do
    attributes :id

    node :full_name do |receiver|
      receiver.full_name
    end
  end

  child :product do
    attributes :id, :name

    node :attachment do |product|
      product.attachments.first.name.url if product.attachments.present?
    end
  end

  node :created_at do |review|
    review.created_at.strftime("%B %d, %Y")
  end
end