# == Schema Information
#
# Table name: products
#
#  id                :integer          not null, primary key
#  name              :string
#  category_id       :integer
#  description       :text
#  location          :string
#  special_condition :text
#  deposit           :decimal(, )
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  size              :string
#  latitude          :string
#  longitude         :string
#  aasm_state        :string
#  one_hour          :decimal(, )      default("0")
#  four_hours        :decimal(, )      default("0")
#  one_day           :decimal(, )      default("0")
#  one_week          :decimal(, )      default("0")
#

require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
