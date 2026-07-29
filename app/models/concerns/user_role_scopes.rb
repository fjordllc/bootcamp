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
  end
end
