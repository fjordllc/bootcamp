# frozen_string_literal: true

class SchedulerController < ApplicationController
  skip_before_action :require_active_user_login, raise: false
  skip_before_action :verify_authenticity_token
  before_action :require_token

  protected

  def require_token
    configured_token = ENV['TOKEN']
    token = params[:token]
    return if configured_token.present? && token.is_a?(String) && token.present? &&
              ActiveSupport::SecurityUtils.secure_compare(token, configured_token)

    head :unauthorized
  end
end
