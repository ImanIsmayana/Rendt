# == Schema Information
#
# Table name: checkouts
#
#  id         :integer          not null, primary key
#  payment_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#  aasm_state :string
#  total_paid :decimal(, )
#

require 'test_helper'

class CheckoutTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
