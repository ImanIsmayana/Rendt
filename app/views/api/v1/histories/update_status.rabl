if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
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

  node(:status){ 200 }
end