# == Schema Information
#
# Table name: checkout_items
#
#  id            :integer          not null, primary key
#  product_id    :integer
#  checkout_id   :integer
#  price         :decimal(, )
#  rent_time     :string
#  total_price   :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deposit       :decimal(, )
#  start_time    :datetime         default("2016-05-04 10:07:19")
#  end_time      :datetime
#  reminder_time :datetime
#  item_type     :string
#

class CheckoutItem < ActiveRecord::Base
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

  aasm(:item_type) do
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
  belongs_to :checkout
  belongs_to :product
  belongs_to :junkyard_product

  before_update :set_duration_and_reminder_time, :if => lambda { |item| item.item_type.eql? 'product' }

  #
  # validations
  #
  validates :product_id, :checkout_id, presence: true

  attr_accessor :duration_code

  #
  # scoping
  #
  scope :product_only, -> { where("item_type != 'junkyard'") }

  def set_duration_and_reminder_time
    self.start_time = Time.now.utc

    case self.duration_code
    when "1h"
      self.rent_time = "one_hour"
      self.price = self.product.one_hour
      self.end_time = self.start_time + 1.hour
      self.reminder_time = self.start_time + 30.minutes
      self.total_price = self.price.to_f + self.deposit.to_f
    when "4h"
      self.rent_time = "four_hours"
      self.price = self.product.four_hours
      self.end_time = self.start_time + 4.hours
      self.reminder_time = self.start_time + 2.hours
      self.total_price = self.price.to_f + self.deposit.to_f
    when "1d"
      self.rent_time = "one_day"
      self.price = self.product.one_day
      self.end_time = self.start_time + 1.day
      self.reminder_time = self.start_time + 12.hours
      self.total_price = self.price.to_f + self.deposit.to_f
    when "1w"
      self.rent_time = "one_week"
      self.price = self.product.one_week
      self.end_time = self.start_time + 1.week
      self.reminder_time = self.start_time + 4.days
      self.total_price = self.price.to_f + self.deposit.to_f
    end

    # puts self.to_json
  end

  def get_price(duration_code)
    case duration_code
    when "1h"
      self.product.one_hour
    when "4h"
      self.product.four_hours
    when "1d"
      self.product.one_day
    when "1w"
      self.product.one_week
    end
  end

  def get_rent_time(duration_code)
    duration = ''
    end_time = nil
    reminder_time = nil

    case duration_code
    when "1h"
      duration = "one_hour"
      end_time = self.start_time + 1.hour
      reminder_time = self.start_time + 30.minutes
    when "4h"
      duration = "four_hours"
      end_time = self.start_time + 4.hours
      reminder_time = self.start_time + 2.hours
    when "1d"
      duration = "one_day"
      end_time = self.start_time + 1.day
      reminder_time = self.start_time + 12.hours
    when "1w"
      duration = "one_week"
      end_time = self.start_time + 1.week
      reminder_time = self.start_time + 4.days
    end

    [duration, end_time, reminder_time]
  end

  def set_hash(lend_by)
    product = self.product
    is_confirm_request = 
      if self.aasm_state.eql? 'approved'
        true
      else
        false
      end

    {
      checkout_item: {
        id: self.id,
        renter_id: self.checkout.user_id,
        lend_by: lend_by,
        price: self.price.to_f,
        deposit: self.deposit.to_f,
        start_time: self.start_time,
        end_time: self.end_time,
        item_type: self.item_type,
        pay_key: self.checkout.pay_key,
        confirm_request: self.aasm_state,
        product: {
          id: product.id,
          name: product.name,
          aasm_state: product.aasm_state,
          rent_status: product.rent_status,
          user: {
            id: product.user_id,
            name: product.user.full_name
          }
        },
        is_confirm_request: is_confirm_request,
      }
    }
  end

  #
  # scheduler based on rent duration
  #
  def self.reminder_one_hour
    checkout_items = CheckoutItem.includes(:product, :checkout => [:user => :mobile_platform])
      .select("checkout_items.*")
      .where("@((DATE_PART('hour', now()) * 60 + DATE_PART('minute', now())) - (DATE_PART('hour', end_time) * 60 +
        DATE_PART('minute', end_time))) < 30 AND now() < end_time AND rent_time = ?", "one_hour")

    self.send_notifications(checkout_items)
  end

  def self.reminder_four_hours
    checkout_items = CheckoutItem.includes(:product, :checkout => [:user => :mobile_platform])
      .select("checkout_items.*")
      .where("@((DATE_PART('hour', now()) * 60 + DATE_PART('minute', now())) - (DATE_PART('hour', end_time) * 60 +
        DATE_PART('minute', end_time))) < 60 AND now() < end_time AND rent_time = ?", "four_hours")

    self.send_notifications(checkout_items)
  end

  def self.reminder_one_day
    checkout_items = CheckoutItem.includes(:product, :checkout => [:user => :mobile_platform])
      .select("checkout_items.*")
      .where("@((DATE_PART('hour', now()) * 60 + DATE_PART('minute', now())) - (DATE_PART('hour', end_time) * 60 +
        DATE_PART('minute', end_time))) < 180 AND now() < end_time AND rent_time = ?", "one_day")

    self.send_notifications(checkout_items)
  end

  def self.reminder_one_week
    checkout_items = CheckoutItem.includes(:product, :checkout => [:user => :mobile_platform])
      .select("checkout_items.*")
      .where("@(DATE_PART('day', now()) - DATE_PART('day', end_time)) <= 1 AND now() < end_time AND rent_time = ?", "one_week")

    self.send_notifications(checkout_items)
  end

  def self.send_notifications(checkout_items)
    checkout_items.each do |checkout_item|
      mobile_platform = checkout_item.checkout.user.mobile_platform

      activity = PublicActivity::Activity.new
      body_message = "Your rent time for product #{checkout_item.product.name} will be end soon. It will be end at #{checkout_item.end_time.to_s}"

      # send notification to mobile
      activity.send_notification_to_mobile('Return Rent Item Reminder', body_message, mobile_platform)
    end
  end
end
