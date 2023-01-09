# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :admin_login?,
                  :mentor_login?,
                  :admin_or_mentor_login?,
                  :adviser_login?,
                  :staff_login?,
                  :student_login?,
                  :paid_login?,
                  :staff_or_paid_login?,
                  :hibernated_login?,
                  :retired_login?
  end

  def admin_login?
    logged_in? && current_user.admin?
  end

  def mentor_login?
    logged_in? && current_user.mentor?
  end

  def admin_or_mentor_login?
    logged_in? && current_user.admin_or_mentor?
  end

  def adviser_login?
    logged_in? && current_user.adviser?
  end

  def staff_login?
    logged_in? && current_user.staff?
  end

  def student_login?
    logged_in? && current_user.student?
  end

  def paid_login?
    logged_in? && current_user.paid?
  end

  def staff_or_paid_login?
    logged_in? && current_user.staff_or_paid?
  end

  def hibernated_login?
    logged_in? && current_user.hibernated?
  end

  def retired_login?
    logged_in? && current_user.retired?
  end

  def require_mentor_login
    return if mentor_login?

    redirect_to root_path, alert: 'メンターとしてログインしてください'
  end

  def require_admin_login
    return if admin_login?

    redirect_to root_path, alert: '管理者としてログインしてください'
  end

  def require_admin_or_mentor_login
    return if admin_or_mentor_login?

    redirect_to root_path, alert: '管理者・メンターとしてログインしてください'
  end

  def require_staff_login
    return if staff_login?

    redirect_to root_path, alert: '管理者・アドバイザー・メンターとしてログインしてください'
  end

  def refuse_retired_login
    return unless retired_login?

    logout
    redirect_to root_path, alert: '退会したユーザーです。'
  end

  def refuse_hibernated_login
    return unless hibernated_login?

    logout
    link = view_context.link_to '休会復帰ページ', new_comeback_path, target: '_blank', rel: 'noopener'
    redirect_to root_path, alert: "休会中です。#{link}から手続きをお願いします。"
  end

  protected

  def not_authenticated
    redirect_to root_path, alert: 'ログインしてください'
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
