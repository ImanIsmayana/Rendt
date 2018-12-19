node(:error){ @error }
node(:errors){ @errors }
node(:response){ @response }
child @payment do |payment|
  attributes :id, :paypal_email, :user_id
  node(:status){ 201 }
end