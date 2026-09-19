# frozen_string_literal: true

# ユーザーの役割(管理者・メンター・アドバイザー・研修生など)に関する責務をまとめたもの。
module UserRole
  extend ActiveSupport::Concern

  included do
    scope :advisers, -> { where(adviser: true) }
    scope :not_advisers, -> { where(adviser: false) }
    scope :mentor, -> { where(mentor: true) }
    scope :admins, -> { where(admin: true) }
    scope :job_seeking, -> { where(career_path: 'job_seeking') }
    scope :trainees, lambda {
      where(
        trainee: true,
        training_completed_at: nil
      )
    }
    scope :admins_and_mentors, -> { admins.or(mentor) }
    scope :job_seekers, lambda {
      where(
        admin: false,
        mentor: false,
        adviser: false,
        trainee: false,
        hibernated_at: nil,
        retired_on: nil,
        job_seeker: true
      )
    }
  end

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

  def student_or_trainee?
    student? || trainee?
  end

  def student_or_trainee_or_retired?
    !staff? && !graduated?
  end
end
