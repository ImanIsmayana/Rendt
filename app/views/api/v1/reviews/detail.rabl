node(:error){ @error }
node(:errors){ @errors }
child @review do
  attributes :id, :quality, :price, :deposit, :service, :tool_safely, :return_on_time, :return_in_good_and_clean,
    :overall_rating, :comment, :target_id, :target_type, :user_id

  node(:product_id) { |review| review.product_id }
end