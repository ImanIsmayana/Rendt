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
#  product_id               :integer
#  aasm_state               :string
#

class Review < ActiveRecord::Base
  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :unread, :initial => true
    state :read

    event :is_unread do
      transitions :from => :read, :to => :unread
    end

    event :is_open do
      transitions :form => :unread, :to => :read
    end
  end

  #
  # relations
  #
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :target, class_name: "User", foreign_key: "target_id"
  belongs_to :product, class_name: "Product", foreign_key: "product_id"

  #
  # validations
  #
  validates_presence_of :target_id, :target_type, :comment

  attr_accessor :review_id
end
