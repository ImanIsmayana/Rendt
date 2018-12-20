if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }
end
child @favourites, object_root: false do
  child :favouritable, root: 'lender' do
    attributes :id, :email, :full_name, :address, :phone_number, :latitude, :longitude

    node(:full_name) { |user| user.full_name }

    node :is_liked do |product|
      current_user.liked? product rescue false
    end

    node :is_favourited do |target|
      target.favourited_by?
    end
  end
end