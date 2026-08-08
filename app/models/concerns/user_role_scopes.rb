# frozen_string_literal: true

module UserRoleScopes
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
end
