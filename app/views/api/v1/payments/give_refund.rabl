node(:error){ @error }
node(:errors){ @errors }
node do
  if @product.aasm_state.eql? 'available'
    node(:is_available) { true }
  else
    node(:is_available) { false }
  end

  if @product.aasm_state.eql? 'not_available'
    node(:is_not_available) { true }
  else
    node(:is_not_available) { false }
  end

  if @product.aasm_state.eql? 'not_yet_returned'
    node(:is_not_yet_returned) { true }
  else
    node(:is_not_yet_returned) { false }
  end

  if @product.aasm_state.eql? 'returned'
    node(:is_returned) { true }
  else
    node(:is_returned) { false }
  end
end

node do
  if @product.rent_status.eql? 'not_rent'
    node(:is_not_rent) { true }
  else
    node(:is_not_rent) { false }
  end

  if @product.rent_status.eql? 'taken'
    node(:is_taken) { true }
  else
    node(:is_taken) { false }
  end

  if @product.rent_status.eql? 'rent'
    node(:is_rent) { true }
  else
    node(:is_rent) { false }
  end

  if @product.rent_status.eql? 'need_refunded'
    node(:is_need_refunded) { true }
  else
    node(:is_need_refunded) { false }
  end
end
