# frozen_string_literal: true

module UserAssociations1
  extend ActiveSupport::Concern
  included do
    belongs_to :company, optional: true
    belongs_to :course
    has_many :learnings, dependent: :destroy
    has_many :pages, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :reports, dependent: :destroy
    has_many :checks, dependent: :destroy
    has_many :footprints, dependent: :destroy
    has_many :images, dependent: :destroy
    has_many :products, dependent: :destroy
    has_many :questions, dependent: :destroy
    has_many :announcements, dependent: :destroy
    has_many :reactions, dependent: :destroy
    has_many :works, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :events, dependent: :destroy
    has_many :participations, dependent: :destroy
    has_many :regular_event_participations, dependent: :destroy
    has_many :answers, dependent: :destroy
    has_many :watches, dependent: :destroy
    has_many :articles, dependent: :destroy
    has_many :bookmarks, dependent: :destroy
    has_many :regular_events, dependent: :destroy
    has_many :regular_event_organizers, dependent: :destroy
    has_many :hibernations, dependent: :destroy
    has_many :authored_books, dependent: :destroy
    accepts_nested_attributes_for :authored_books, allow_destroy: true
    has_many :surveys, dependent: :destroy
    has_many :survey_questions, dependent: :destroy
    has_many :external_entries, dependent: :destroy
    has_many :movies, dependent: :nullify
    has_many :coding_tests, dependent: :destroy
    has_many :coding_test_submissions, dependent: :destroy
    has_one :report_preset, dependent: :destroy
    has_one :talk, dependent: :destroy
    has_one :discord_profile, dependent: :destroy
    accepts_nested_attributes_for :discord_profile, allow_destroy: true
    has_many :request_retirements, dependent: :destroy
    has_one :targeted_request_retirement, class_name: 'RequestRetirement', foreign_key: 'target_user_id', dependent: :destroy, inverse_of: :target_user
    has_many :micro_reports, dependent: :destroy
    has_many :authored_micro_reports, class_name: 'MicroReport', foreign_key: 'comment_user_id', dependent: :destroy, inverse_of: :comment_user
    has_many :learning_time_frames_users, dependent: :destroy
    has_many :pair_works, dependent: :destroy
  end
end
