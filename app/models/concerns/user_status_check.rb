# frozen_string_literal: true

module UserStatusCheck
  extend ActiveSupport::Concern

  def student?
    !admin? && !adviser? && !mentor? && !trainee?
  end

  def current_student?
    !admin? && !adviser? && !mentor? && !graduated? && !retired?
  end

  def staff?
    admin? || mentor? || adviser?
  end

  def staff_or_paid?
    staff? || paid?
  end

  def admin_or_mentor?
    admin? || mentor?
  end

  def adviser_or_mentor?
    adviser? || mentor?
  end

  def hibernated?
    hibernated_at?
  end

  def after_twenty_nine_days_registration?
    twenty_nine_days = Time.current.ago(29.days).to_date
    created_at.to_date.before? twenty_nine_days
  end

  def followup_message_target?
    current_student? && !hibernated? && after_twenty_nine_days_registration? && !sent_student_followup_message
  end

  def training_completed?
    training_completed_at?
  end

  def retired?
    retired_on?
  end

  def inactive?
    hibernated_at? || training_completed_at? || retired_on?
  end

  def graduated?
    graduated_on?
  end

  def student_or_trainee?
    student? || trainee?
  end

  def student_or_trainee_or_retired?
    !staff? && !graduated?
  end
end
