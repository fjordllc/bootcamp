# frozen_string_literal: true

module Authentication::LoginHelpers
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
                  :training_completed_login?,
                  :retired_login?,
                  :inactive_login?
  end

  def admin_login?
    logged_in? && current_user.admin?
  end

  def mentor_login?
    logged_in? && current_user.mentor?
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

  def hibernated_login?
    logged_in? && current_user.hibernated?
  end

  def training_completed_login?
    logged_in? && current_user.training_completed?
  end

  def trainee_login?
    logged_in? && current_user.trainee?
  end

  def retired_login?
    logged_in? && current_user.retired?
  end

  def admin_or_mentor_login?
    logged_in? && current_user.admin_or_mentor?
  end

  def inactive_login?
    logged_in? && current_user.inactive?
  end
end
