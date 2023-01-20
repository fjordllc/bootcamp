ActiveSupport::Reloader.to_prepare do
  Rails.application.configure do
    config.active_storage.variable_content_types << "image/heic"
    config.active_storage.variable_content_types << "image/heif"
  end
end