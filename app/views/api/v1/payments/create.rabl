node(:error){ @error }
node(:errors){ @errors }
node(:response){ @response }
child @payment do |payment|
  attributes :id, :paypal_email, :user_id
end