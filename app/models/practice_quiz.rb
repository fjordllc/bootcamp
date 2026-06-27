# frozen_string_literal: true

class PracticeQuiz < ApplicationRecord
  COOLDOWN = 1.hour

  belongs_to :practice
  has_many :practice_quiz_questions, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :practice_quiz
  has_many :practice_quiz_attempts, dependent: :destroy

  accepts_nested_attributes_for :practice_quiz_questions, allow_destroy: true

  validates :practice_id, uniqueness: true
  validate :published_quiz_must_have_published_questions

  scope :published, -> { where(published: true) }

  def published_questions
    practice_quiz_questions.published
  end

  def passed_attempt_for(user)
    practice_quiz_attempts.where(user:, passed: true).order(submitted_at: :desc).first
  end

  def passed_by?(user)
    passed_attempt_for(user).present?
  end

  def latest_attempt_for(user)
    practice_quiz_attempts.where(user:).order(submitted_at: :desc).first
  end

  def next_attempt_at_for(user)
    latest_attempt = latest_attempt_for(user)
    return if latest_attempt.blank?

    latest_attempt.submitted_at + COOLDOWN
  end

  def attemptable_by?(user)
    return false if passed_by?(user)

    next_attempt_at = next_attempt_at_for(user)
    next_attempt_at.blank? || next_attempt_at <= Time.current
  end

  private

  def published_quiz_must_have_published_questions
    return unless published?
    return if published_questions.any?

    errors.add(:base, '公開中の理解度テストには公開中の問題が必要です。')
  end
end
