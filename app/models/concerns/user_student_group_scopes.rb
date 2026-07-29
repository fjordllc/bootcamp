# frozen_string_literal: true

module UserStudentGroupScopes
  extend ActiveSupport::Concern

  included do
    scope :students_and_trainees, lambda {
      where(
        admin: false,
        mentor: false,
        adviser: false,
        graduated_on: nil,
        hibernated_at: nil,
        retired_on: nil,
        training_completed_at: nil
      )
    }
    scope :students_trainees_mentors_and_admins, lambda {
      where(
        adviser: false,
        graduated_on: nil,
        hibernated_at: nil,
        retired_on: nil
      )
    }
    scope :students_base, lambda {
      where(
        admin: false,
        mentor: false,
        adviser: false,
        trainee: false,
        hibernated_at: nil,
        graduated_on: nil
      )
    }
    scope :students, -> { students_base.unretired }
    scope :retired_students, -> { students_base.retired }
  end
end
