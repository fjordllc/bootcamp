# frozen_string_literal: true

module Authentication::AccessRequirements
  extend ActiveSupport::Concern

  def require_active_user_login
    if inactive_login?
      deny_inactive_user_login
    else
      require_login
    end
  end

  def require_admin_login
    return if admin_login?

    redirect_to root_path, alert: '管理者としてログインしてください'
  end

  def require_mentor_login
    return if mentor_login?

    redirect_to root_path, alert: 'メンターとしてログインしてください'
  end

  def require_admin_or_mentor_login
    return if admin_or_mentor_login?

    redirect_to root_path, alert: '管理者・メンターとしてログインしてください'
  end

  def require_staff_login
    return if staff_login?

    redirect_to root_path, alert: '管理者・アドバイザー・メンターとしてログインしてください'
  end

  protected

  def require_admin_or_adviser_login
    return if admin_login? || (adviser_login? && current_user.company == @company)

    redirect_to root_path, alert: '管理者・アドバイザーとしてログインしてください'
  end
end
