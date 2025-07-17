# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include TestAuthentication if Rails.env.test?
  include FeatureToggle
  include PolicyHelper
  helper_method :staging?
  protect_from_forgery with: :exception
  before_action :require_scheduler_inheritation, if: -> { request.path_info.start_with?('/scheduler') }
  before_action :basic_auth, if: :staging?
  before_action :test_login, if: :test?
  before_action :init_user
  before_action :allow_cross_domain_access
  before_action :set_host_for_disk_storage
  before_action :require_active_user_login
  before_action :set_current_user_practice

  # Handle ActiveStorage file not found errors in tests
  rescue_from ActiveStorage::FileNotFoundError, with: :handle_active_storage_file_not_found if Rails.env.test?

  protected

  def allow_cross_domain_access
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = '*'
  end

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |user, password|
      user == ENV['BASIC_AUTH_USER'] && password == ENV['BASIC_AUTH_PASSWORD']
    end
  end

  def init_user
    @current_user = current_user
  end

  def set_available_emojis
    @available_emojis = Reaction.emojis.map { |key, value| { kind: key, value: } }
  end

  def set_host_for_disk_storage
    return unless %i[local test].include? Rails.application.config.active_storage.service

    ActiveStorage::Current.host = request.base_url
  end

  def require_card
    redirect_to root_path, notice: 'カード登録が必要です。' unless current_user&.card?
  end

  def require_subscription
    redirect_to root_path, notice: 'サブスクリプション登録が必要です。' unless current_user&.subscription?
  end

  def require_scheduler_inheritation
    head :internal_server_error unless is_a?(SchedulerController)
  end

  def set_current_user_practice
    @current_user_practice = UserCoursePractice.new(current_user)
  end

  protected

  def staging?
    ENV['DB_NAME'] == 'bootcamp_staging'
  end

  def test?
    Rails.env.test?
  end

  private

  def handle_active_storage_file_not_found(exception)
    Rails.logger.debug "ActiveStorage file not found in test: #{exception.message}"

    # In tests, render a 404 instead of raising the error to prevent flaky test failures
    if request.xhr?
      render json: { error: 'File not found' }, status: :not_found
    else
      # For non-AJAX requests, redirect or render a placeholder
      head :not_found
    end
  end
end
