if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node(:rent) { @rent }
node(:lend) { @lend }
if @error.eql? 0
  node(:status){ 200 }
end