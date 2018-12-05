# == Schema Information
#
# Table name: checkouts
#
#  id            :integer          not null, primary key
#  payment_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :integer
#  aasm_state    :string
#  total_paid    :decimal(, )
#  pay_key       :string
#  checkout_type :string
#

class Checkout < ActiveRecord::Base
  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :pending, :initial => true
    state :cancelled
    state :approved
    state :wait_approval

    event :is_wait_approval do
      transitions :form => [:pending, :approved], :to => :wait_approval
    end

    event :is_approved do
      transitions :from => [:pending, :cancelled, :wait_approval], :to => :approved
    end

    event :is_pending do
      transitions :from => [:approved, :cancelled, :wait_approval], :to => :pending
    end

    event :is_cancelled do
      transitions :from => [:pending, :approved], :to => :cancelled
    end
  end

  #
  # set type checkout item product or junkyard
  #
  aasm(:checkout_type) do
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
  # payment status whether paid or not paid
  #
  aasm(:pay_status) do
    state :not_paid, :initial => true
    state :paid
    state :free
    
    event :is_not_paid do
      transitions :from => :paid, :to => :not_paid
    end

    event :is_paid do
      transitions :from => :not_paid, :to => :paid
    end

    event :is_free do
      transitions :from => :not_paid, :to => :free
    end
  end

  #
  # relations
  #
  has_many :checkout_items, dependent: :destroy
  belongs_to :payment
  belongs_to :user

  #
  # scoping active record
  #
  scope :paid, -> { where("transaction_id IS NOT NULL AND pay_status = 'paid' AND checkout_type = 'product'") }
  scope :junkyard, -> { where("pay_status = 'free' AND checkout_type = 'junkyard'") }

  def self.get_checkout_junkyard_or_product(checkout_product, checkout_junkyard)
    product_hash = checkout_product.set_hash if checkout_product
    junkyard_hash = checkout_junkyard.set_hash if checkout_junkyard

    if checkout_product && checkout_junkyard
      product_hash.merge(junkyard_hash)
    elsif checkout_product
      product_hash.merge({ checkout_junkyard: { checkout_items: [] } })
    else
      junkyard_hash.merge({ checkout_product: { checkout_items: [] } })
    end
  end

  def set_hash
    checkout_key = "checkout_#{self.checkout_type}".to_sym

    checkout_hash = {
      "#{checkout_key}": {
        id: self.id,
        checkout_type: self.checkout_type,
        checkout_items: []
      },
    }

    self.set_items_hash(checkout_hash, checkout_key)
  end

  def set_items_hash(checkout_hash, checkout_key)
    self.checkout_items.each do |item_product|
      product = item_product.product

      checkout_item_hash = { 
        checkout_item: { 
          id: item_product.id,
          price: item_product.price,
          rent_time: item_product.rent_time,
          deposit: item_product.deposit.to_f,
          total_price: item_product.total_price.to_f,
          product: {
            id: product.id,
            name: product.name,
            one_hour: product.one_hour.to_f,
            four_hours: product.four_hours.to_f,
            one_day: product.one_day.to_f,
            one_week: product.one_week.to_f,
            user: {
              id: product.user_id,
              name: product.user.full_name
            }
          }
        }
      }
    
      checkout_hash[checkout_key][:checkout_items] << checkout_item_hash
    end

    checkout_hash
  end

  def self.get_review_checkout_junkyard_or_product(checkout_product, checkout_junkyard)
    product_hash = checkout_product.set_review_hash if checkout_product
    junkyard_hash = checkout_junkyard.set_review_hash if checkout_junkyard

    if checkout_product && checkout_junkyard
      checkout = product_hash.merge(junkyard_hash)
    elsif checkout_product
      product_hash
    else
      junkyard_hash
    end
  end

  def set_review_hash
    checkout_key = "checkout_#{self.checkout_type}".to_sym

    checkout_hash = {
      "#{checkout_key}": {
        id: self.id,
        payment: {
          id: self.payment_id,
          paypal_email: self.payment_id ? self.payment.paypal_email : nil,
        },
        aasm_state: self.aasm_state,
        total_paid: self.total_paid.to_f,
        checkout_type: self.checkout_type,
        checkout_items: []
      },
    }

    self.set_items_review_hash(checkout_hash, checkout_key)
  end

  def set_items_review_hash(checkout_hash, checkout_key)
    self.checkout_items.includes(:product).each do |item_product|
      product = item_product.product

      checkout_item_hash = { 
        checkout_item: { 
          id: item_product.id,
          price: item_product.price,
          rent_time: item_product.rent_time,
          deposit: item_product.deposit.to_f,
          total_price: item_product.total_price.to_f,
          product: {
            id: product.id,
            name: product.name,
            user: {
              id: product.user_id,
              name: product.user.full_name
            }
          }
        }
      }
    
      checkout_hash[checkout_key][:checkout_items] << checkout_item_hash
    end

    checkout_hash
  end

  def self.get_lender_with_each_amount(id)
    lenders_with_each_amount = self.joins(:checkout_items => [:product => [:user => :payments]])
      .select("payments.user_id AS id, payments.paypal_email, SUM(total_price - ((total_price * 0.03) + 1)) AS AMOUNT")
      .where("checkouts.id = ?", id).group("payments.paypal_email, payments.user_id")
  end
  
  def self.get_list_of_checkouts(object, status = nil, inactive_histories = nil, method_name = nil)
    checkout_item_array = []
    renter = object.renter
    
    renter.checkouts.paid.includes(:checkout_items => [:product => :user]).each do |checkout|
      lend_by = renter.full_name if status.eql? 'lend'
      
      checkout.checkout_items.product_only.each do |checkout_item|
        checkout_items_hash = {}

        if method_name.eql? 'my_order'
          if inactive_histories.present?
            inactive_histories.each do |inactive_history|
              unless inactive_history.product_id.eql? checkout_item.product_id
                checkout_items_hash = checkout_item.set_hash(lend_by)
              end
            end
          else
            checkout_items_hash = checkout_item.set_hash(lend_by)
          end
        else
          checkout_items_hash = checkout_item.set_hash(lend_by)
        end

        checkout_item_array << checkout_items_hash
      end
    end

    checkout_item_array
  end

  def calculate_total_price_based_on_lender
    total_price_per_lender1 = 0
    total_price_per_lender2 = 0
    pay_params = {}

    self.checkout_items.includes(:product => :user).each do |checkout_item|
      lender_email = checkout_item.product.user.payments.active.first.paypal_email

      if checkout_item.product_id > 1
        total_price_per_lender1 += checkout_item.price.to_f
        pay_params[lender_email] = total_price_per_lender1
      else
        total_price_per_lender2 += checkout_item.price.to_f
        pay_params[lender_email] = total_price_per_lender2
      end 
    end

    pay_params
  end

  def set_payment_receivers_with_amount
    total_price_lenders = calculate_total_price_based_on_lender
    receivers = []

    total_price_lenders.each do |total_price_lender|
      tool_price = total_price_lender.last
      lender_email = total_price_lender.first
      app_fee = (total_price_lender.last.to_f * 10) / 100
      total_tool_price = tool_price - app_fee

      #
      # for production please used real paypal email
      #
      receivers << { email: lender_email, amount: total_tool_price, primary: false }
    end

    receivers
  end

  def get_payment_per_lender(group_by = nil)
    lender_hash = {}

    self.checkout_items.includes(:product => :user).each do |checkout_item|
      hash_key = 
        if group_by.eql? :lender_id
          checkout_item.product.user_id
        else
          checkout_item.product.user.payments.active.first.paypal_email
        end

      if lender_hash[hash_key]
        lender_hash[hash_key] += checkout_item.price.to_f
      else
        lender_hash[hash_key] = checkout_item.price.to_f
      end 
    end

    lender_hash
  end

  def generate_payment_per_lender_hash(group_by = nil)
    payment_per_lender_hash = get_payment_per_lender(group_by)
    receivers = []

    payment_per_lender_hash.each do |key, amount|
      app_fee = (10 / 100.0) * amount
      net_amount = amount - app_fee

      #
      # for production please used real paypal email
      #
      if group_by.eql? :lender_id
        receivers << { id: key, amount: net_amount }
      else
        receivers << { email: key, amount: net_amount, primary: false }
      end
    end

    receivers
  end

  def request_payments
    api = PayPal::SDK::AdaptivePayments.new

    receivers = generate_payment_per_lender_hash
    receivers << { email: api.config.sandbox_email_address, amount: self.total_paid, primary: true }
    
    sender_email = self.payment.paypal_email
    
    request = PaypalAdaptivePayments.build_pay(receivers, sender_email)

    request
  end

  def request_single_payments
    api = PayPal::SDK::AdaptivePayments.new

    sender_email = self.payment.paypal_email
    request = PaypalAdaptivePayments.single_payment(self.total_paid, sender_email)

    request
  end
end
