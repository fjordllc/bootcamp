# frozen_string_literal: true

require 'test_helper'

class PracticeQuizTest < ActiveSupport::TestCase
  test 'published quiz requires published questions' do
    quiz = PracticeQuiz.new(practice: practices(:practice1), published: true)

    assert_not quiz.valid?
    assert_includes quiz.errors.full_messages, '公開中の理解度テストには公開中の問題が必要です。'
  end

  test '#passed_by?' do
    quiz = create_quiz(practices(:practice1))

    assert_not quiz.passed_by?(users(:kimura))

    PracticeQuizAttempt.create!(practice_quiz: quiz, user: users(:kimura), submitted_at: Time.current, passed: true)

    assert quiz.passed_by?(users(:kimura))
  end

  test '#attemptable_by?' do
    quiz = create_quiz(practices(:practice1))
    user = users(:kimura)

    assert quiz.attemptable_by?(user)

    PracticeQuizAttempt.create!(practice_quiz: quiz, user:, submitted_at: 30.minutes.ago, passed: false)

    assert_not quiz.attemptable_by?(user)

    PracticeQuizAttempt.create!(practice_quiz: quiz, user:, submitted_at: 61.minutes.ago, passed: false)

    assert_not quiz.attemptable_by?(user), 'latest attempt is still within cooldown'
  end

  test '#attemptable_by? returns true after one hour from latest attempt' do
    quiz = create_quiz(practices(:practice1))
    user = users(:kimura)
    PracticeQuizAttempt.create!(practice_quiz: quiz, user:, submitted_at: 61.minutes.ago, passed: false)

    assert quiz.attemptable_by?(user)
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
