# == Schema Information
#
# Table name: checkout_items
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  checkout_id :integer
#  price       :decimal(, )
#  rent_time   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deposit     :decimal(, )
#  total_price :decimal(, )
#

require 'test_helper'

class CheckoutItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
