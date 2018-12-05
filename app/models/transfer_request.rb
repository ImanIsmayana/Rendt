class TransferRequest < ActiveRecord::Base
  belongs_to :user

  include AASM
  aasm do
    state :pending, :initial => true
    state :approved

    event :is_pending do
      transitions :from => :approved, :to => :pending
    end

    event :is_approved do
      transitions :from => :pending, :to => :approved
    end
  end

  #
  # scoping
  #
  scope :pending, -> { where(aasm_state: :pending) }
end
