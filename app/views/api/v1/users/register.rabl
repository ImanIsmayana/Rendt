if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
  node(:user){ "nil" }
end
if @error.eql? 0
  node(:status){ 200 }
  node(:user){ @user }
end
