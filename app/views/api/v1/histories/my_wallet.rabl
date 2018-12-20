if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node(:balance) { @user.balance.to_f }
node(:total_spend) { @total_spend }
node(:total_income) { @total_income }
node(:is_transfer_request) { @is_transfer_request }
if @error.eql? 0
  node(:status){ 200 }
end