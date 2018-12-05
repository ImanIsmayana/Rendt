# == Schema Information
#
# Table name: mobile_platforms
#
#  id           :integer          not null, primary key
#  device_id    :string
#  device_model :string
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class MobilePlatform < ActiveRecord::Base
  belongs_to :user

  #
  # validations
  #
  validates :device_id, :device_model, presence: true
end
