if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
  # node(:carts) { @null }
end

if @error.eql? 0
  if @carts.present?
    node(:carts) { @carts }
    # node :attachment do |image|
    #   image.url if image.present?
    # end
  end
  node(:status){ 200 }
end