# frozen_string_literal: true

module UserActiveScopes
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(last_activity_at: 1.month.ago..Float::INFINITY) }
    scope :inactive, lambda {
      where(
        last_activity_at: Date.new..1.month.ago,
        adviser: false,
        hibernated_at: nil,
        retired_on: nil,
        graduated_on: nil
      )
    }
    scope :inactive_students_and_trainees, -> { inactive.where(admin: false, mentor: false, training_completed_at: nil) }
    scope :working, lambda {
      active.where(
        adviser: false,
        graduated_on: nil,
        hibernated_at: nil,
        retired_on: nil
      ).order(last_activity_at: :desc)
    }
    scope :active_tagged_with, ->(tag_name) { with_attached_avatar.unretired.unhibernated.order(last_activity_at: :desc).tagged_with(tag_name) }
  end
end
