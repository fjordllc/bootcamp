# frozen_string_literal: true

class API::PubSubController < API::BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login_for_api
  skip_before_action :basic_auth
  before_action :authenticate_pubsub_token, unless: -> { Rails.env.test? }

  def create
    result = ProcessTranscodingNotification.call(body: request.body.read)

    if result.success?
      head :ok
    else
      Rails.logger.error("Failed to process transcoding notification: #{result.error}")

      if result.retryable == false
        head :ok # 200系のステータスコードを返すとPub/Subは再送しない
      else
        head :internal_server_error
      end
    end
  end

  private

  def authenticate_pubsub_token
    authz = request.headers['Authorization'].to_s
    token = authz[/\ABearer\s+(.+)\z/i, 1]
    return if token && valid_pubsub_token?(token)

    Rails.logger.warn('Unauthorized Pub/Sub request')
    head :unauthorized
  end

  def valid_pubsub_token?(token)
    validator = GoogleIDToken::Validator.new
    expected_audience = "#{request.base_url}#{request.path}"
    payload = validator.check(token, expected_audience)

    expected_sa_email = ENV['PUBSUB_SERVICE_ACCOUNT_EMAIL']
    sa_email_claim = payload['email']
    sa_email_claim == expected_sa_email
  rescue GoogleIDToken::ValidationError => e
    Rails.logger.warn("Invalid JWT: #{e.message}")
    false
  end
end
