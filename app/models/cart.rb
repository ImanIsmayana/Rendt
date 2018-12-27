# == Schema Information
#
# Table name: carts
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  aasm_state :string
#

class Cart < ActiveRecord::Base
  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :product, :initial => true
    state :junkyard

    event :is_product do
      transitions :from => :junkyard, :to => :product
    end

    event :is_junkyard do
      transitions :from => :product, :to => :junkyard
    end
  end

  include JunkyardAndProduct

  belongs_to :user
  belongs_to :product
  belongs_to :junkyard_product, class_name: 'JunkyardProduct', foreign_key: :product_id

  def self.get_all_of_carts(user_id, page)
    carts = self.includes(:user, :junkyard_product => [:category, :user, :attachments],
      :product => [:category, :user, :attachments]).where(user_id: user_id).page(page).per(10)

    cart_array = []

    carts.each do |cart|
      cart_array << { cart: cart.set_response }
    end

    cart_array
  end

  def set_response
    item =
      if self.aasm_state.eql? 'product'
       self.product
      else
        self.junkyard_product
      end

    {
      aasm_state: self.aasm_state,
      product: {
        id: item.id,
        name: item.name,
        aasm_state: item.aasm_state,
        description: item.description,
        category: item.category.name,
        product_location: item.location,
        longitude: item.longitude,
        latitude: item.latitude,
        price_per_one_hour: item.one_hour,
        price_per_four_hour: item.four_hours,
        price_per_day: item.one_day,
        price_per_week: item.one_week,
        deposit: item.deposit
      }
    }
  end
end
