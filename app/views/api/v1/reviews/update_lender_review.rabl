node(:error){ @error }
node(:errors){ @errors }
child @review do
  attribute :id, :quality, :price, :deposit, :service, :tool_safety, :return_to_home, :return_in_good_and_clean,
    :overall_rating, :comment

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

  node(:product_id) { |review| review.product_id }

  node :created_at do |review|
    review.created_at.strftime("%B %d, %Y")
  end
  node(:status){ 200 }
end