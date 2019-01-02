if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:product){ @item.name }
  node(:status){ 201 }
end