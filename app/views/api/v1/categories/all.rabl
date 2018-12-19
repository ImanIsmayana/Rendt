node(:error){ @error }
node(:errors){ @errors }
child @categories do
  attributes :id, :name, :image

  node :attachment do |category|
    category.attachments.first.name.url if category.attachments.present?
  end

  node(:status){ 200 }
end

node(:product_count) { @product_count }
node(:junkyard_count) { @junkyard_count }