if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end
if @error.eql? 0
  node(:status){ 201 }
end
child @category do
  attributes :id, :name
  node :attachment do |category|
    category.attachments.first.name.url if category.attachments.present?
  end
end