# frozen_string_literal: true

module SmartSearch
  class GoogleCloudCredentials
    class << self
      def setup_credentials!
        # Google Cloud SDKの標準的な認証方法をそのまま使用
        # 優先順位：
        # 1. GOOGLE_APPLICATION_CREDENTIALS環境変数（ファイルパス）
        # 2. gcloud auth application-default login で設定されたデフォルト認証
        # 3. Google Cloud環境での自動認証（Cloud Run, GKEなど）
        
        if ENV['GOOGLE_APPLICATION_CREDENTIALS'].present?
          if File.exist?(ENV['GOOGLE_APPLICATION_CREDENTIALS'])
            Rails.logger.info "Using Google Cloud credentials from file: #{ENV['GOOGLE_APPLICATION_CREDENTIALS']}"
          else
            Rails.logger.warn "GOOGLE_APPLICATION_CREDENTIALS file not found: #{ENV['GOOGLE_APPLICATION_CREDENTIALS']}"
          end
        else
          Rails.logger.debug 'GOOGLE_APPLICATION_CREDENTIALS not set, using default authentication'
        end
      end

      def project_id
        Rails.application.credentials.dig(:google_cloud, :project_id) || ENV['GOOGLE_CLOUD_PROJECT']
      end
    end
  end
end
