# == Schema Information
#
# Table name: lends
#
#  id         :integer          not null, primary key
#  product_id :integer
#  user_id    :integer
#  start_date :datetime
#  end_time   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class LendTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
