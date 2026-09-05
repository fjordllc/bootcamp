# frozen_string_literal: true

module UserContentAssociations
  extend ActiveSupport::Concern

  included do
    has_many :pages, dependent: :destroy
    has_many :comments, dependent: :destroy
    has_many :reports, dependent: :destroy
    has_many :articles, dependent: :destroy
    has_many :questions, dependent: :destroy
    has_many :announcements, dependent: :destroy
    has_many :movies, dependent: :nullify
    has_many :micro_reports, dependent: :destroy
    has_many :authored_micro_reports, class_name: 'MicroReport', foreign_key: 'comment_user_id', dependent: :destroy, inverse_of: :comment_user
    has_many :surveys, dependent: :destroy
    has_many :survey_questions, dependent: :destroy
    has_many :authored_books, dependent: :destroy
    accepts_nested_attributes_for :authored_books, allow_destroy: true
    has_one :talk, dependent: :destroy
    has_one :report_preset, dependent: :destroy
    has_many :images, dependent: :destroy
    has_many :works, dependent: :destroy
    has_many :external_entries, dependent: :destroy
    has_many :watches, dependent: :destroy
    has_many :reactions, dependent: :destroy
    has_many :footprints, dependent: :destroy
    has_many :answers, dependent: :destroy
    has_many :bookmarks, dependent: :destroy
    has_many :notifications, dependent: :destroy
  end
end
