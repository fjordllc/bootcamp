# frozen_string_literal: true

module UserLearningAssociations
  extend ActiveSupport::Concern

  included do
    has_many :learnings, dependent: :destroy
    has_many :checks, dependent: :destroy
    has_many :products, dependent: :destroy
    has_many :coding_tests, dependent: :destroy
    has_many :coding_test_submissions, dependent: :destroy
    has_many :pair_works, dependent: :destroy
    has_many :completed_learnings, -> { where(status: 'complete') }, class_name: 'Learning', inverse_of: 'user', dependent: :destroy
    has_many :active_learnings, -> { where(status: 'started') }, class_name: 'Learning', inverse_of: 'user', dependent: :destroy
    has_many :completed_practices, through: :completed_learnings, source: :practice, dependent: :destroy
    has_many :active_practices, through: :active_learnings, source: :practice, dependent: :destroy
    has_many :skipped_practices, dependent: :destroy
    has_many :practices, through: :skipped_practices
    has_many :learning_time_frames_users, dependent: :destroy
    has_many :learning_time_frames, through: :learning_time_frames_users
  end
end
