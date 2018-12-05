# == Schema Information
#
# Table name: junkyard_products
#
#  id                :integer          not null, primary key
#  name              :string
#  description       :text
#  location          :string
#  special_condition :text
#  size              :string
#  latitude          :string
#  longitude         :string
#  aasm_state        :string
#  category_id       :integer
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  favourites_count  :integer          default("0")
#

class JunkyardProduct < ActiveRecord::Base
  #
  # junkyard and products
  #
  include JunkyardAndProduct

  #
  # aasm configuration
  #
  include AASM
  aasm do
    state :available, :initial => true
    state :not_available
    state :deleted

    event :is_available do
      transitions :from => [:not_available, :deleted], :to => :available
    end

    event :is_not_available do
      transitions :from => [:available, :deleted], :to => :not_available
    end

    event :delete do
      transitions :from => [:available, :not_available], :to => :deleted
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
  has_many :rent_histories

  belongs_to :category
  belongs_to :user

  #
  # validations
  #
  validates :name, :category_id, :description, :location, :latitude, :longitude, :user_id, presence: true
  validates :name, length: { minimum: 3, maximum: 100 }

  #
  # scoping
  #
  scope :active, -> { where("aasm_state != 'deleted'") }

  def favourited_by?(user)
    favourites.where(user_id: user).present? ? true : false
  end

  def get_list_active_junkyard_products
    self.get_list_active_junkyard_products
  end

  def self.get_list_active_junkyard_products
    self.includes(:attachments, :category).active
      .select(:id, :name, :category_id, :aasm_state, :description, :location, :latitude, :longitude)
  end
end
