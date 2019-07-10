# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :admin_login?,
      :adviser_login?,
      :mentor_login?,
      :staff_login?,
      :paid_login?,
      :staff_or_paid_login?,
      :admin_adviser_or_mentor_login?
  end

  def admin_login?
    logged_in? && current_user.admin?
  end

  def adviser_login?
    logged_in? && current_user.adviser?
  end

  def mentor_login?
    logged_in? && current_user.mentor?
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

  def admin_adviser_or_mentor_login?
    admin_login? || adviser_login? || mentor_login?
  end

  def require_admin_login
    unless admin_login?
      redirect_to root_path, alert: "管理者としてログインしてください"
    end
  end

  def require_staff_login
    unless staff_login?
  end

  def require_admin_adviser_or_mentor_login
    unless admin_adviser_or_mentor_login?
      redirect_to root_path, alert: "管理者・アドバイザー・メンターとしてログインしてください"
    end
  end

  def require_paid_login
    unless paid_login? || current_user.free?
      redirect_to new_card_path, alert: "クレジットカードを登録してください"
    end
  end

  def require_staff_or_paid_login
    unless staff_or_paid_login? || current_user.free?
      redirect_to new_card_path, alert: "クレジットカードを登録してください"
    end
  end

  protected
    def not_authenticated
      redirect_to root_path, alert: "ログインしてください"
    end
  end
end
