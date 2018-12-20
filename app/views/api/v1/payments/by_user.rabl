if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

  child @payments do
    attributes :id, :paypal_email, :aasm_state
    node(:first_name) { @user.first_name }
  end
end