# frozen_string_literal: true

require 'test_helper'

class PracticeQuizAttemptTest < ActiveSupport::TestCase
  test '.create_with_answers! passes only when all published questions are correct' do
    quiz = create_quiz
    single_choice = quiz.practice_quiz_questions.single_choice.first
    multiple_choice = quiz.practice_quiz_questions.multiple_choice.first
    answers = {
      single_choice.id.to_s => [single_choice.practice_quiz_choices.find_by!(correct: true).id],
      multiple_choice.id.to_s => multiple_choice.practice_quiz_choices.where(correct: true).pluck(:id)
    }

    attempt = PracticeQuizAttempt.create_with_answers!(practice_quiz: quiz, user: users(:kimura), answers:)

    assert_predicate attempt, :passed?
  end

  test '.create_with_answers! fails when one question is unanswered' do
    quiz = create_quiz
    single_choice = quiz.practice_quiz_questions.single_choice.first
    answers = {
      single_choice.id.to_s => [single_choice.practice_quiz_choices.find_by!(correct: true).id]
    }

    attempt = PracticeQuizAttempt.create_with_answers!(practice_quiz: quiz, user: users(:kimura), answers:)

    assert_not_predicate attempt, :passed?
  end

  test '.create_with_answers! stores answers after an incorrect question' do
    quiz = create_quiz
    single_choice = quiz.practice_quiz_questions.single_choice.first
    multiple_choice = quiz.practice_quiz_questions.multiple_choice.first
    answers = {
      single_choice.id.to_s => [single_choice.practice_quiz_choices.find_by!(correct: false).id],
      multiple_choice.id.to_s => multiple_choice.practice_quiz_choices.where(correct: true).pluck(:id)
    }

    attempt = PracticeQuizAttempt.create_with_answers!(practice_quiz: quiz, user: users(:kimura), answers:)

    assert_not_predicate attempt, :passed?
    assert_equal 3, attempt.practice_quiz_answers.count
  end

  private

  def create_quiz
    quiz = PracticeQuiz.create!(practice: practices(:practice1), published: false)
    create_single_choice(quiz)
    create_multiple_choice(quiz)
    quiz.update!(published: true)
    quiz
  end

  def create_single_choice(quiz)
    question = quiz.practice_quiz_questions.create!(question_type: :single_choice, body: '単一選択です。', position: 1, published: false)
    question.practice_quiz_choices.create!(body: '正解', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 2)
    question.update!(published: true)
  end

  def create_multiple_choice(quiz)
    question = quiz.practice_quiz_questions.create!(question_type: :multiple_choice, body: '複数選択です。', position: 2, published: false)
    question.practice_quiz_choices.create!(body: '正解1', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '正解2', correct: true, position: 2)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 3)
    question.update!(published: true)
  end
end
