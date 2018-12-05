# == Schema Information
#
# Table name: favourites
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  favouritable_id   :integer
#  favouritable_type :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Favourite < ActiveRecord::Base
  #
  # relations
  #
  belongs_to :favouritable, polymorphic: true

  #
  # validations
  #
  validates :user_id, :favouritable_id, :favouritable_type, presence: true

  #
  # active record callback
  #
  after_create :increment_favourites_count, :if => lambda { |f| f.favouritable_type.eql? 'Product' }
  after_destroy :decrement_favourites_count, :if => lambda { |f| f.favouritable_type.eql? 'Product' }

  #
  # get all favourites based on current user and type
  #
  def self.get_all(user_id, favouritable_type)
    self.includes(:favouritable).where(user_id: user_id, favouritable_type: favouritable_type)
  end

  def self.get_favourites(user_id, favouritable_id, favouritable_type)
    self.where(user_id: user_id, favouritable_id: favouritable_id, favouritable_type: favouritable_type)
  end

  def self.get_favourites_or_create(user_id, favouritable_id, favouritable_type)
    user_favourites = self.get_favourites(user_id, favouritable_id, favouritable_type).exists?

    unless user_favourites
      self.or_create(user_id, favouritable_id, favouritable_type)
    end
  end

  def self.or_create(user_id, favouritable_id, favouritable_type)
    Favourite.create(
      user_id: user_id, 
      favouritable_id: favouritable_id,
      favouritable_type: favouritable_type,
    )
  end

  private
    def increment_favourites_count
      self.favouritable.increment_favourites_counter
    end

    def decrement_favourites_count
      self.favouritable.decrement_favourites_counter
    end
end
