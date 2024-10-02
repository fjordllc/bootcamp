# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  include Authentication::LoginHelpers
  include Authentication::AccessRequirements

  protected

  def not_authenticated
    redirect_to root_path, alert: 'ログインしてください'
  end

  def deny_hibernated_or_retired_login
    if hibernated_login?
      logout
      link = view_context.link_to '休会復帰ページ', new_comeback_path, target: '_blank', rel: 'noopener'
      redirect_to root_path, alert: "休会中です。#{link}から手続きをお願いします。"
    elsif retired_login?
      logout
      redirect_to root_path, alert: '退会したユーザーです。'
    end
  end

  def require_login_for_api
    login_from_jwt unless logged_in?
    head :unauthorized unless logged_in?
  end

  def require_admin_login_for_api
    login_from_jwt unless logged_in?
    head :unauthorized unless admin_login?
  end

  def require_mentor_login_for_api
    login_from_jwt unless logged_in?
    head :unauthorized unless mentor_login?
  end

  def require_staff_login_for_api
    login_from_jwt unless logged_in?
    head :unauthorized unless staff_login?
  end
end
