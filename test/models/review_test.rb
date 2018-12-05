# == Schema Information
#
# Table name: reviews
#
#  id                       :integer          not null, primary key
#  quality                  :integer          default("0")
#  price                    :integer          default("0")
#  deposit                  :integer          default("0")
#  service                  :integer          default("0")
#  tool_safely              :integer          default("0")
#  return_on_time           :integer          default("0")
#  return_in_good_and_clean :integer          default("0")
#  overall_rating           :integer          default("0")
#  comment                  :text
#  user_id                  :integer
#  target_id                :integer
#  target_type              :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

require 'test_helper'

class ReviewTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
