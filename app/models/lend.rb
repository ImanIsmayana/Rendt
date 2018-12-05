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

class Lend < ActiveRecord::Base
  #
  # relations
  #
  has_one :checkout
  belongs_to :user
  belongs_to :product

  #
  # validations
  #
  validates :product_id, :user_id, :start_date, :end_date, presence: true
end
