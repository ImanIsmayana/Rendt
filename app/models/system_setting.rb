class SystemSetting < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  after_update :reset_cache

  validates :name, :email_sender, :listing_per_page, :maintenance_message, presence: true

  def logo_uploader_hint
    hint_text = 'Upload 128x128 logo in jpg, gif, or png format'

    if self.logo.try(:file).try(:exists?)
      hint_text << "<br/><img src='#{self.logo.url}' class='current-logo'/>"
    end

    hint_text
  end

  def self.cached
    Rails.cache.fetch(:system_setting) { self.first }
  end

  private
    def reset_cache
      Rails.cache.delete(:system_setting)
    end
end
