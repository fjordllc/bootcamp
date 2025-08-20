# frozen_string_literal: true

# Google Cloud credentials setup
Rails.application.config.after_initialize do
  begin
    SmartSearch::GoogleCloudCredentials.setup_credentials!
  rescue StandardError => e
    Rails.logger.warn "Google Cloud credentials setup failed: #{e.message}"
    Rails.logger.warn "Smart Search and embedding features will be disabled"
    # Continue application startup without failing
  end
end