if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 200 }
end
node do
  if @rent_status.eql? 'not_rent'
    node(:is_not_rent) { true }
  else
    node(:is_not_rent) { false }
  end

  if @rent_status.eql? 'taken'
    node(:is_taken) { true }
  else
    node(:is_taken) { false }
  end

  if @rent_status.eql? 'rent'
    node(:is_rent) { true }
  else
    node(:is_rent) { false }
  end

  if @rent_status.eql? 'need_refunded'
    node(:is_need_refunded) { true }
  else
    node(:is_need_refunded) { false }
  end
end