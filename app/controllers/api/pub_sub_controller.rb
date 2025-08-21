# frozen_string_literal: true

class API::PubSubController < API::BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login_for_api
  skip_before_action :basic_auth
  before_action :authenticate_pubsub_token

  def create
    result = ProcessTranscodingNotification.call(body: request.body.read)

    Rails.logger.error("Failed to process transcoding notification: #{result.error}") unless result.success?

    head :ok
  end

  private

  def authenticate_pubsub_token
    token = request.headers['Authorization']&.delete_prefix('Bearer ')
    return if token && valid_pubsub_token?(token)

    Rails.logger.warn('Unauthorized Pub/Sub request')
    head :unauthorized
  end

  def valid_pubsub_token?(token)
    validator = GoogleIDToken::Validator.new
    expected_audience = ENV['PUBSUB_AUDIENCE'].presence
    payload = validator.check(token, expected_audience)

    expected_sa_email = ENV['PUBSUB_SERVICE_ACCOUNT_EMAIL'].presence

    sa_email_claim = payload['email']
    sa_email_claim == expected_sa_email
  rescue GoogleIDToken::ValidationError => e
    Rails.logger.warn("Invalid JWT: #{e.message}")
    false
  end
end
