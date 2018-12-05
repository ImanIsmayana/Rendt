node(:error){ @error }
node(:errors){ @errors }
child @payment do |payment|
  attributes :id, :paypal_email, :user_id
end