# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ActiveStorage::SetCurrent
  include Authentication
  include TestAuthentication if Rails.env.test?
  include PolicyHelper
  helper_method :staging?
  protect_from_forgery with: :exception
  before_action :require_scheduler_inheritation, if: -> { request.path_info.start_with?('/scheduler') }
  before_action :basic_auth, if: :staging?
  before_action :test_login, if: :test?
  before_action :init_user
  before_action :require_active_user_login
  before_action :set_current_user_practice
  before_action :save_affiliate_rd_code

  private

  def basic_auth
    authenticate_or_request_with_http_basic do |user, password|
      configured_user = ENV['BASIC_AUTH_USER']
      configured_password = ENV['BASIC_AUTH_PASSWORD']
      next false unless configured_user.present? && configured_password.present? && user.is_a?(String) && password.is_a?(String)

      ActiveSupport::SecurityUtils.secure_compare(user, configured_user) &
        ActiveSupport::SecurityUtils.secure_compare(password, configured_password)
    end
  end

  def init_user
    @current_user = current_user
  end

  def set_available_emojis
    @available_emojis = Reaction.emojis.map { |key, value| { kind: key, value: } }
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

  def save_affiliate_rd_code
    rd_code = params[:rd_code]
    return if rd_code.blank?

    if rd_code.match?(/\A[\w-]{1,128}\z/)
      session[:affiliate_rd_code] = rd_code
    else
      Rails.logger.warn("[Affiliate] Invalid rd_code received: #{rd_code.truncate(200)}")
    end
  end

  protected

  def staging?
    ENV['DB_NAME'] == 'bootcamp_staging'
  end

  def test?
    Rails.env.test?
  end
end
