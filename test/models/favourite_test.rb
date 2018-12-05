# == Schema Information
#
# Table name: favourites
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  favouritable_id   :integer
#  favouritable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'test_helper'

class FavouriteTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
