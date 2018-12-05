# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Category < ActiveRecord::Base
  #
  # relations
  #
  has_many :products
  has_many :junkyard_products
  has_many :attachments, as: :attachable

  #
  # validations
  #
  validates :name, presence: true

  #
  # uploader configuration
  #
  mount_uploader :image, ImageUploader

  #
  # scoping
  #
  default_scope { order('name asc') }

  #
  # update all favourites count, this method used for developer
  #
  def update_product_favourites_count
    self.products.each do |product|
      favourites_count = product.favourites.size
      product.update(favourites_count: favourites_count)
    end
  end

  def update_junkyard_product_favourites_count
    self.junkyard_products.each do |product|
      favourites_count = product.favourites.size
      product.update(favourites_count: favourites_count)
    end
  end
end
