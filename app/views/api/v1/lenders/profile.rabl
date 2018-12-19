node(:error){ @error }
node(:errors){ @errors }
child @lender, root: 'lender', object_root: false do
  attributes :id, :email, :full_name, :address, :phone_number, :latitude, :longitude, :hide_address, :description

  node do |lender|
    if lender.favourites.size > 0
      { :is_favourited => true }
    else
      { :is_favourited => false }
    end
  end

  node(:review_count) { @review_count }
  node(:status){ 200 }
end
