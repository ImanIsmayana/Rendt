if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node(:refund_info) { @refund_info }
node(:time) { @time }
if @error.eql? 0
  node(:status){ 200 }
end