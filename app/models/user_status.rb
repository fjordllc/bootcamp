# frozen_string_literal: true

class UserStatus
  def initialize(user)
    @user = user
  end

  def student?
    !@user.admin? && !@user.adviser? && !@user.mentor? && !@user.trainee?
  end

  def current_student?
    !@user.admin? && !@user.adviser? && !@user.mentor? && !graduated? && !retired?
  end

  def staff?
    @user.admin? || @user.mentor? || @user.adviser?
  end

  def staff_or_paid?
    staff? || @user.paid?
  end

  def admin_or_mentor?
    @user.admin? || @user.mentor?
  end

  def adviser_or_mentor?
    @user.adviser? || @user.mentor?
  end

  def hibernated?
    @user.hibernated_at?
  end

  def after_twenty_nine_days_registration?
    twenty_nine_days = Time.current.ago(29.days).to_date
    @user.created_at.to_date.before? twenty_nine_days
  end

  def followup_message_target?
    current_student? && !hibernated? && after_twenty_nine_days_registration? && !@user.sent_student_followup_message
  end

  def training_completed?
    @user.training_completed_at?
  end

  def retired?
    @user.retired_on?
  end

  def inactive?
    @user.hibernated_at? || @user.training_completed_at? || @user.retired_on?
  end

  def graduated?
    @user.graduated_on?
  end

  def student_or_trainee?
    student? || @user.trainee?
  end

  def student_or_trainee_or_retired?
    !staff? && !graduated?
  end
end
