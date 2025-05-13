class TranscodingJob < ApplicationJob
  queue_as :default

  POLLING_INTERVAL = 60.seconds

  private

  def transcoder_client
    @transcoder_client ||= Google::Cloud::Video::Transcoder.transcoder_service
  end

  def bucket_name
    active_storage_config["bucket"]
  end

  def project_id
    active_storage_config["project"]
  end

  def location
    "asia-northeast1"
  end

  def active_storage_config
    Rails.application.config.active_storage.service_configurations["google"]
  end

  def production_only
    return unless Rails.env.production?
    yield
  end
end
