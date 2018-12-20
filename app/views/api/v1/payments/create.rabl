if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
node(:response){ @response }
if @error.eql? 0
  node(:status){ 200 }

  child @payment do |payment|
    attributes :id, :paypal_email, :user_id
  end
end
