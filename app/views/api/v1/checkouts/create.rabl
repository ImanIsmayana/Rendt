if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:checkout) { @checkout }
  node(:status){ 201 }
end