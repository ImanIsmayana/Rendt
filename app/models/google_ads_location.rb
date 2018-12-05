class GoogleAdsLocation < ActiveRecord::Base
  validates :name, :width, :location, :number, :status, :sort_order, presence: true
end
