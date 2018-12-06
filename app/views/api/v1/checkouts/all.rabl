node(:error){ @error }
node(:errors){ @errors }
child @checkouts do
  attributes :id, :aasm_state

  child :checkout_items do
    attributes :id, :price, :rent_time, :deposit, :total_price, :start_time, :end_time

    child :product do
      attributes :id, :name

      child(:user) do
        attributes :id
        
        node(:name){|user| user.full_name}
      end
    end
  end
end