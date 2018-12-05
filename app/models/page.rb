class Page < ActiveRecord::Base
  mount_uploader :banner, BannerUploader
  
  extend FriendlyId
  friendly_id :meta_title, use: :slugged

  scope :menus, -> (position) { 
    select('id, slug, menu_title').where(active: true).order('menu_sort_order, menu_title ASC')
      .where('menu_position = ? OR menu_position = ?', position, 'both')
  }

  has_one :attachment, as: :attachable

  accepts_nested_attributes_for :attachment

  validates :heading, :url, :meta_title, :meta_description, :short_intro, :content,
    :menu_title, :menu_sort_order, presence: true

  validates :menu_position, presence: { message: 'Please select one' }

  def banner_uploader_hint
    hint_text = 'Upload 1280x375 banner in jpg, gif or png format.'

    if self.banner.try(:file).try(:exists?)
      hint_text << "<br/><img src='#{self.banner.url}' class='current-banner'/>"
    end

    hint_text
  end

  def attachment_uploader_hint
    hint_text = 'Upload 128x128 thumbnail in jpg, gif, or png format.'

    if self.try(:attachment).try(:name).try(:file).try(:exists?)
      hint_text << "<br/><img src='#{self.attachment.name.url}' class='current-thumbnail'/>"
    end

    hint_text
  end

  def self.first_three
    self.includes(:attachment).select(:id, :slug, :menu_title, :short_intro).order(id: :asc).limit(3)
  end

  def self.cached_top_menus
    Rails.cache.fetch(:top_menus) { Page.menus('top') }
  end

  def self.cached_bottom_menus
    Rails.cache.fetch(:bottom_menus) { Page.menus('bottom') }
  end
end
