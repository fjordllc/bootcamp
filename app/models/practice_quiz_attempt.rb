# frozen_string_literal: true

class PracticeQuizAttempt < ApplicationRecord
  belongs_to :practice_quiz
  belongs_to :user
  has_many :practice_quiz_answers, dependent: :destroy

  validates :submitted_at, presence: true

  def self.create_with_answers!(practice_quiz:, user:, answers:)
    attempt = new(practice_quiz:, user:, submitted_at: Time.current)
    questions = practice_quiz.published_questions.includes(:practice_quiz_choices)

    transaction do
      question_results = build_answers_for_questions(attempt, questions, answers)
      attempt.passed = questions.any? && question_results.all?
      attempt.save!
    end

    attempt
  end

  def self.build_answers_for_questions(attempt, questions, answers)
    questions.map do |question|
      choice_ids = Array(answers[question.id.to_s] || answers[question.id]).reject(&:blank?)
      build_answers_for_question(attempt, question, choice_ids)
      question.correct_answer?(choice_ids)
    end
  end
  private_class_method :build_answers_for_questions

  def self.build_answers_for_question(attempt, question, choice_ids)
    choice_ids.each do |choice_id|
      choice = question.practice_quiz_choices.detect { |candidate| candidate.id == choice_id.to_i }
      next if choice.blank?

      attempt.practice_quiz_answers.build(practice_quiz_question: question, practice_quiz_choice: choice, correct: choice.correct?)
    end
  end
  private_class_method :build_answers_for_question
end
