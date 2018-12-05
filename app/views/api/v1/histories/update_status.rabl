node(:error){ @error }
node(:errors){ @errors }
node do
  if @status.eql? 'rented'
    node(:is_rented) { true }
  else
    node(:is_rented) { false }
  end

  if @status.eql? 'returned'
    node(:is_returned) { true }
  else
    node(:is_returned) { false }
  end
end