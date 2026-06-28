# frozen_string_literal: true

class PracticeQuizQuestion < ApplicationRecord
  enum :question_type, { single_choice: 0, multiple_choice: 1 }

  belongs_to :practice_quiz
  has_many :practice_quiz_choices, -> { order(:position, :id) }, dependent: :destroy, inverse_of: :practice_quiz_question
  has_many :practice_quiz_answers, through: :practice_quiz_choices

  before_destroy :published_quiz_must_keep_published_question

  accepts_nested_attributes_for :practice_quiz_choices, allow_destroy: true, reject_if: :choice_blank?

  validates :body, presence: true
  validates :position, presence: true
  validate :published_question_must_have_valid_choices
  validate :published_quiz_must_have_published_question

  scope :published, -> { where(published: true).order(:position, :id) }

  def correct_choice_ids
    practice_quiz_choices.select(&:correct?).map(&:id).sort
  end

  def correct_answer?(choice_ids)
    selected_choice_ids = Array(choice_ids).reject(&:blank?).map(&:to_i).sort
    selected_choice_ids.present? && selected_choice_ids == correct_choice_ids
  end

  private

  def choice_blank?(attributes)
    ActiveModel::Type::Boolean.new.cast(attributes['_destroy']) || attributes['body'].blank?
  end

  def published_question_must_have_valid_choices
    return unless published?

    active_choices = practice_quiz_choices.reject(&:marked_for_destruction?)
    correct_choices = active_choices.select(&:correct?)

    errors.add(:base, '公開中の問題には2つ以上の選択肢が必要です。') if active_choices.size < 2
    errors.add(:base, '公開中の問題には正解が必要です。') if correct_choices.empty?
    errors.add(:base, '単一選択の正解は1つだけにしてください。') if single_choice? && correct_choices.size != 1
  end

  def published_quiz_must_have_published_question
    return unless practice_quiz&.published?
    return if published?
    return if practice_quiz.practice_quiz_questions.published.where.not(id:).exists?

    errors.add(:base, '公開中の理解度テストには公開中の問題が必要です。')
  end

  def published_quiz_must_keep_published_question
    return unless practice_quiz&.published?
    return unless published?
    return if practice_quiz.practice_quiz_questions.published.where.not(id:).exists?

    errors.add(:base, '公開中の理解度テストには公開中の問題が必要です。')
    throw :abort
  end
end
