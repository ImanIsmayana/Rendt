if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }

  child @user do
    attributes :address, :latitude, :longitude, :user_id, :authentication_token, :hide_address

    if @error.eql? 0
      node(:id){ @user_id }
      node(:authentication_token){ @authentication_token }
    end
  end
end