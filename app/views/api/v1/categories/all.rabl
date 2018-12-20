if @error.eql? 1
  node(:error){ @error }
  node(:errors){ @errors }
end

if @error.eql? 0
  node(:status){ 200 }
end

child @categories do
  attributes :id, :name, :image

  node :attachment do |category|
     category.attachments.first.name.url if category.attachments.present?
  end

  # node :image_url do |image|
  #   ENV['RENDT'] + image.image_url if image.image_url.present?
  # end

end


node(:product_count) { @product_count }
node(:junkyard_count) { @junkyard_count }