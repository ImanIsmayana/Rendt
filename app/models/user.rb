# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default("0"), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  first_name             :string
#  last_name              :string
#  address                :text
#  latitude               :string
#  longitude              :string
#  authentication_token   :string
#  phone_number           :string
#

class User < ActiveRecord::Base
  include PublicActivity::Model

  #
  # simple token authentication configuration
  #
  acts_as_token_authenticatable

  #
  # acts as messageable configuration
  #
  acts_as_messageable :required   => :body,
                      :dependent  => :destroy

  #
  # acts as votable configuration - as voter
  #
  acts_as_voter

  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable, :confirmable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #
  # relations
  #
  has_many :products
  has_many :checkouts
  has_many :payments
  has_many :favourites, as: :favouritable, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :carts, dependent: :destroy
  has_many :junkyard_products
  has_many :wallets
  has_many :transfer_requests

  has_one :mobile_platform, dependent: :destroy
  has_one :attachment, as: :attachable

  #
  # validations
  #
  # validates :first_name, :last_name, :address, :latitude, :longitude, :phone_number, presence: true
  # validates :first_name, :last_name, length: {minimum: 3, maximum: 30}

  #
  # nested attributes form
  #
  accepts_nested_attributes_for :attachment

  #
  # Send confirmation instructions by email
  #
  def send_confirmation_instructions
    unless @raw_confirmation_token
      generate_confirmation_token!
    end

    opts = pending_reconfirmation? ? { to: unconfirmed_email } : { }
    send_devise_notification(:confirmation_instructions, @raw_confirmation_token, opts)
  end

  #
  # User favourited
  #
  def favourited_by?
    favourites.where(favouritable_id: self.id).present? ? true : false
  end

  #
  # return user first name and last name combined
  #
  def full_name
    return "#{first_name} #{last_name}"
  end

  #
  # return attachment uploader hint based on user data
  #
  def attachment_uploader_hint
    hint_text = 'Upload 500x500 image in jpg, gif, or png format.'

    if self.try(:attachment).try(:name).try(:file).try(:exists?)
      hint_text << "<br/><img src='#{self.attachment.name.url}' class='current-user-image'/>"
    end

    hint_text
  end

  #
  # get all of user or lenders that have products
  #
  def self.get_lender_have_products
    self.joins(:products).uniq.all
  end

  def self.get_profile(id)
    self.includes(:products)
      .select(:id, :address, :email, :first_name, :last_name, :phone_number, :latitude, :longitude,
        :hide_address, :description)
      .find_by(id: id)
  end
end
