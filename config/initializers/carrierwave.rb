CarrierWave.configure do |config|
  config.storage = :file
  config.permissions = 0666
  config.directory_permissions = 0777
  config.cache_dir = "#{Rails.root}/tmp/uploads"
end
