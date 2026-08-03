# frozen_string_literal: true

module UserPracticeProgressAssociations
  extend ActiveSupport::Concern

  included do
    has_many :completed_practices,
             through: :completed_learnings,
             source: :practice,
             dependent: :destroy

    has_many :active_practices,
             through: :active_learnings,
             source: :practice,
             dependent: :destroy

    has_many :skipped_practices,
             dependent: :destroy

    has_many :practices,
             through: :skipped_practices

    has_many :learning_time_frames_users, dependent: :destroy

    has_many :learning_time_frames,
             through: :learning_time_frames_users
  end
end
