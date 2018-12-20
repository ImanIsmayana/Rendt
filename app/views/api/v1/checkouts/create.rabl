if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node(:checkout) { @checkout }
if @error.eql? 0
  node(:status){ 201 }
end