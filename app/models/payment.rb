# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  paypal_email :string
#  user_id      :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  aasm_state   :string
#

class Payment < ActiveRecord::Base
  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :default, :initial => true
    state :inactive

    event :is_default do
      transitions :from => :inactive, :to => :default
    end

    event :is_inactive do
      transitions :from => :default, :to => :inactive
    end
  end

  before_create :deactive_status, :if => lambda { |p| p.aasm_state.eql? 'default' }

  #
  # scoping
  #
  scope :active, -> { where("aasm_state != 'inactive'") }
  scope :not_active, -> { where("aasm_state != 'default'") }

  #
  # relations
  #
  belongs_to :user
  has_one :checkout

  #
  # validations
  #
  validates :paypal_email, :user_id, presence: true

  attr_accessor :status

  # def self.check_status(status)
  #   case status
  #   when 'default'
  #     :default
  #   else
  #     :inactive
  #   end
  # end

  private
    def deactive_status
      payment = Payment.active.find_by(user_id: self.user_id)
      payment.update(aasm_state: :inactive) if payment
    end
end
