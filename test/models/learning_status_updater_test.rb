# frozen_string_literal: true

require 'test_helper'

class LearningStatusUpdaterTest < ActiveSupport::TestCase
  test '#update_after_check keeps submitted when product practice quiz is not passed' do
    user = users(:kimura)
    practice = practices(:practice5)
    create_quiz(practice)
    product = Product.create!(user:, practice:, body: '提出物です。')
    check = product.checks.create!(user: users(:mentormentaro))

    LearningStatusUpdater.new.update_after_check(check)

    assert Learning.find_by!(user:, practice:).submitted?
  end

  test '#update_after_check completes when product practice quiz is passed' do
    user = users(:kimura)
    practice = practices(:practice5)
    quiz = create_quiz(practice)
    PracticeQuizAttempt.create!(practice_quiz: quiz, user:, submitted_at: Time.current, passed: true)
    product = Product.create!(user:, practice:, body: '提出物です。')
    check = product.checks.create!(user: users(:mentormentaro))

    LearningStatusUpdater.new.update_after_check(check)

    assert Learning.find_by!(user:, practice:).complete?
  end

  private

  def create_quiz(practice)
    quiz = PracticeQuiz.create!(practice:, published: false)
    question = quiz.practice_quiz_questions.create!(
      question_type: :single_choice,
      body: '正しいものを選んでください。',
      position: 1,
      published: false
    )
    question.practice_quiz_choices.create!(body: '正解', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 2)
    question.update!(published: true)
    quiz.update!(published: true)
    quiz
  end
end
