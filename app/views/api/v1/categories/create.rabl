node(:error){ @error }
node(:errors){ @errors }
child @category do
  attributes :id, :name
  node :attachment do |category|
    category.attachments.first.name.url if category.attachments.present?
  end
    node(:status){ 201 }
end