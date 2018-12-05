node(:error){ @error }
node(:errors){ @errors }
child @profile do
  attributes :id, :email, :first_name, :last_name, :address, :latitude, :longitude, :phone_number, 
  :attachment, :authentication_token, :description

  node :attachment do |profile|
    profile.attachment.name.url if profile.attachment.present?
  end

  node do |profile|
    if profile.products.present?
      node(:is_lender) { true }
    else
      node(:is_lender) { false }
    end
  end
end