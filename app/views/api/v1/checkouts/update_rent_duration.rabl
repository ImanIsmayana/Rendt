if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }
end
child @checkout do
  attributes :id, :aasm_state
  node(:total_price_checkout){ @total_price_checkout }
  # node(:total_deposit){ @deposit }
  # node(:total_price){ @price }
  child :checkout_items do
    attributes :id, :price, :rent_time, :deposit, :total_price
    child :product do
      attributes :id, :name
      child(:user) do
        attributes :id
        node(:name){|user| user.full_name}
      end
    end
  end
end