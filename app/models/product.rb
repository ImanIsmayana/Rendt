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
#  one_hour          :decimal(, )      default("0.0")
#  four_hours        :decimal(, )      default("0.0")
#  one_day           :decimal(, )      default("0.0")
#  one_week          :decimal(, )      default("0.0")
#  favourites_count  :integer          default("0")
#  rent_status       :string
#

class Product < ActiveRecord::Base
  #
  # public activity
  #
  include PublicActivity::Model

  #
  # junkyard and products
  #
  include JunkyardAndProduct

  #
  # aasm configuration

  include AASM
  aasm do
    state :not_available
    state :not_yet_returned
    state :returned
    state :available, :initial => true
    state :deleted

    event :is_not_available do
      transitions :from => [:available, :deleted], :to => :not_available
    end

    event :is_not_yet_returned do
      transitions :from => [:not_available, :deleted], :to => :not_yet_returned
    end

    event :is_returned do
      transitions :from => [:not_yet_returned, :deleted], :to => :returned
    end

    event :is_available do
      transitions :from => [:returned, :not_available, :deleted], :to => :available
    end

    event :delete do
      transitions :from => [:available, :not_available], :to => :deleted
    end
  end

  aasm(:rent_status) do
    state :rent
    state :taken
    state :need_refunded
    state :refunded
    state :not_rent, :initial => true

    event :is_rent do
      transitions :form => :not_rent, :to => :rent
    end

    event :is_taken do
      transitions :from => :rent, :to => :taken
    end

    event :is_need_refunded do
      transitions :form => :taken, :to => :need_refunded
    end

    event :is_refunded do
      transitions :form => :need_refunded, :to => :refunded
    end

    event :is_not_rent do
      transitions :form => :refunded, :to => :not_rent
    end
  end

  #
  # acts as votable configuration
  #
  acts_as_votable

  #
  # relations
  #
  has_many :attachments, as: :attachable
  has_many :favourites, as: :favouritable
  has_many :messages, class_name: "ActsAsMessageable::Message", as: :documentable
  has_many :checkout_items
  has_many :rent_histories

  belongs_to :category
  belongs_to :user

  #
  # validations
  #
  validates :name, :category_id, :one_hour, :four_hours, :one_day, :one_week, :description, :location, :latitude, :longitude, :limit, :user_id, presence: true
  validates :name, length: {minimum: 3, maximum: 100}
  validates :one_hour, :four_hours, :one_day, :one_week, numericality: true

  #
  # nested attributes form
  #
  accepts_nested_attributes_for :attachments

  #
  # scoping
  #
  scope :active, -> { where("products.aasm_state != 'deleted'") }

  def favourited_by?(user)
    favourites.where(user_id: user).present? ? true : false
  end

  def countdown
    time = Time.new(0)
    time_now = Time.now.utc
    product_only = self.checkout_items.product_only.last

    if product_only
      end_time = product_only.end_time
      countdown_time_in_seconds = (end_time - time_now).to_i if end_time && time_now < end_time
    end
  end

  def get_list_active_products
    self.get_list_active_products
  end

  def self.get_list_active_products
    self.includes(:attachments, :category, :rent_histories).active
      .select(:id, :name, :category_id, :one_hour, :four_hours, :one_day, :one_week, :deposit, :aasm_state, :description,
        :latitude, :longitude, :location, :rent_status)
  end

  def self.renter_accepeted_refund(id)
    self.select('products.id, products.deposit, checkouts.pay_key, users.id AS user_id')
      .joins(:user, :checkout_items => :checkout).find_by(id: id)
  end

  def self.get_by_price(category_id, rent_time)
    rent_periode =
      case rent_time
      when '1h'
        'one_hour'.to_sym
      when '4h'
        'four_hours'.to_sym
      when '1d'
        'one_day'.to_sym
      else
        'one_week'.to_sym
      end

    self.includes(:category, :attachments).active.where(category_id: category_id).order(rent_periode => 'asc')
  end

  def self.repost_reminder
    old_products = Product.select('products.*, mobile_platforms.device_id, mobile_platforms.device_model')
      .joins(:user => :mobile_platform)
      .where('products.created_at >= ?', 6.month.ago)
      .order('products.updated_at DESC').offset(20)

    old_products.each do |product|
      activity = PublicActivity::Activity.new

      response_notif = activity.create_notification(
        key: 'products.need_repost',
        owner: product.user,
        recipient: product.user,
        notification_type: 'need_repost',
        title_message: 'Product Repost Required',
        body_message: "One of your product, #{product.name} need repost because it covered by new products",
        another_parameters: {
          product_id: product.id,
          product_name: product.name
        }
      )
    end
  end
end
