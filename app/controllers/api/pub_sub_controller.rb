# frozen_string_literal: true

class API::PubSubController < API::BaseController
  skip_before_action :verify_authenticity_token
  skip_before_action :require_login_for_api

  def create
    result = ProcessTranscodingNotification.call(body: request.body.read)

    Rails.logger.error("Failed to process transcoding notification: #{result.error}") unless result.success?

    head :ok
  end
end
