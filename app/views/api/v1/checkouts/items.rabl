node(:error){ @error }
node(:errors){ @errors }
child @checkout_items do
  attributes :id, :price, :rent_time, :deposit, :total_price
  child :product do
    attributes :id, :name
    child(:user) do
      attributes :id
      node(:name){|user| user.full_name}
    end
  end
end