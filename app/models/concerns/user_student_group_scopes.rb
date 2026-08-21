# frozen_string_literal: true

module UserStudentGroupScopes
  extend ActiveSupport::Concern

  included do
    scope :students_and_trainees, -> { students_trainees_mentors_and_admins.where(admin: false, mentor: false, training_completed_at: nil) }
    scope :students_trainees_mentors_and_admins, -> { where(adviser: false, graduated_on: nil, hibernated_at: nil).unretired }
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
