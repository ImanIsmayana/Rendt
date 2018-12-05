node(:error){ @error }
node(:errors){ @errors }
node(:balance) { @user.balance.to_f }
node(:total_spend) { @total_spend }
node(:total_income) { @total_income }
node(:is_transfer_request) { @is_transfer_request }