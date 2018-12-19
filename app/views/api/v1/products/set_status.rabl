node(:error){ @error }
node(:errors){ @errors }
node do
  if @product_status.eql? 'available'
    node(:is_available) { true }
  else
    node(:is_available) { false }
  end

  if @product_status.eql? 'not_available'
    node(:is_not_available) { true }
  else
    node(:is_not_available) { false }
  end

  if @product_status.eql? 'not_yet_returned'
    node(:is_not_yet_returned) { true }
  else
    node(:is_not_yet_returned) { false }
  end

  if @product_status.eql? 'returned'
    node(:is_returned) { true }
  else
    node(:is_returned) { false }
  end
  node(:status){ 200 }
end