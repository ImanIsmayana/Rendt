if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
  # node(:carts) { @null }
end

if @error.eql? 0
  if @carts.present?
    node(:carts) { @carts }
  end
  node(:status){ 200 }
end