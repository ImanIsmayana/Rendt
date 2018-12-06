node(:error){ @error }
node(:errors){ @errors }
child @lenders, root: 'lenders', object_root: false do
  attributes :id, :email, :full_name, :address, :phone_number, :latitude, :longitude, :hide_address

  node do |lender|
    if lender.favourites.size > 0
      { :is_favourited => true }
    else
      { :is_favourited => false }
    end
  end
  
  node(:full_name) { |user| user.full_name }
end