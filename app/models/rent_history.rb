# == Schema Information
#
# Table name: rent_histories
#
#  id         :integer          not null, primary key
#  renter_id  :integer
#  lender_id  :integer
#  rent_time  :string
#  aasm_state :string
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  rent_type  :string
#  price      :decimal(, )
#

class RentHistory < ActiveRecord::Base
  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :rented, :initial => true
    state :returned
    
    event :is_rented do
      transitions :form => [:returned, :rented], :to => :rented
    end

    event :is_returned do
      transitions :from => [:rented, :returned], :to => :returned
    end
  end

  aasm(:rent_type) do
    state :product
    state :junkyard
    
    event :is_product do
      transitions :from => :junkyard, :to => :product
    end

    event :is_junkyard do
      transitions :from => :product, :to => :junkyard
    end
  end

  #
  # relations
  #
  belongs_to :product
  belongs_to :checkout
  belongs_to :checkout_item
  belongs_to :junkyard_product, class_name: 'JunkyardProduct', foreign_key: :product_id
  belongs_to :renter, class_name: 'User', foreign_key: :renter_id
  belongs_to :lender, class_name: 'User', foreign_key: :lender_id

  #
  # scoping
  #
  scope :active, -> { where("aasm_state != 'returned'") }
  scope :inactive, -> { where("aasm_state != 'rented'") }
  scope :product_only, -> { where("aasm_state != 'junkyard'") }

  def self.get_rent_history(user_id)
    self.includes(:renter, :product => :user).where("lender_id = :user_id OR renter_id = :user_id", { user_id: user_id })
  end

  def self.total_spend(user_id)
    self.product_only.where(renter_id: user_id).sum(:price)
  end

  def self.total_income(user_id)
    self.product_only.where(lender_id: user_id).sum(:price)
  end

  def self.get_my_order_hash(user_id, page = nil, active = true)
    rent_histories =  
      if active
        self.active.get_rent_history(user_id).page(page).per(10)
      else
        self.get_rent_history(user_id).page(page).per(10)
      end

    rent_history_groups = rent_histories.group_by do |rent_history|
      rent_history.lender_id.eql?(user_id) ? :lend : :rent
    end

    rent_hash = { rent: nil, lend: nil }

    [:rent, :lend].each do |group_key|
      if rent_history_groups[group_key]
        rent_hash[group_key] = 
          rent_history_groups[group_key].map do |rent_history|
            lend_by = group_key.eql?(:rent) ? rent_history.lender.full_name : rent_history.renter.full_name
            rent_history.checkout_item.set_hash(lend_by)
          end
      end
    end

    rent_hash
  end
end
