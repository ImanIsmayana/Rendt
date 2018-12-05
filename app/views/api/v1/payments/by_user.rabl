node(:error){ @error }
node(:errors){ @errors }
child @payments do
  attributes :id, :paypal_email, :aasm_state
  node(:first_name) { @user.first_name }
end
