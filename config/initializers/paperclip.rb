# frozen_string_literal: true

if Rails.env.production? || Rails.env.staging? || Rails.env.review?
  storage = :fog
else
  storage = :filesystem
end

Paperclip::Attachment.default_options[:storage] = storage
Paperclip::Attachment.default_options[:fog_host] = "https://#{ENV["GOOGLE_STORAGE_BUCKET_NAME"]}.storage.googleapis.com"
Paperclip::Attachment.default_options[:fog_directory] = ENV["GOOGLE_STORAGE_BUCKET_NAME"]
Paperclip::Attachment.default_options[:fog_credentials] = {
  provider: "Google",
  google_storage_access_key_id: ENV["GOOGLE_STORAGE_ACCESS_KEY"],
  google_storage_secret_access_key: ENV["GOOGLE_STORAGE_SECRET"]
}

Paperclip::Attachment.default_options[:s3_host_name] = "s3-ap-northeast-1.amazonaws.com"
