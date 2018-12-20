if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node { @checkout_result }
if @error.eql? 0
  node(:status){ 200 }
end