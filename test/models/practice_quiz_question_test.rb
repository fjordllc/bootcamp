# frozen_string_literal: true

require 'test_helper'

class PracticeQuizQuestionTest < ActiveSupport::TestCase
  test '#correct_answer? returns true when single choice answer matches correct choice' do
    question = create_question(:single_choice)
    correct_choice = question.practice_quiz_choices.find_by!(correct: true)

    assert question.correct_answer?([correct_choice.id])
  end

  test '#correct_answer? requires exact match for multiple choice' do
    question = create_question(:multiple_choice)
    correct_choice_ids = question.practice_quiz_choices.where(correct: true).pluck(:id)
    wrong_choice = question.practice_quiz_choices.find_by!(correct: false)

    assert question.correct_answer?(correct_choice_ids)
    assert_not question.correct_answer?(correct_choice_ids.take(1))
    assert_not question.correct_answer?(correct_choice_ids + [wrong_choice.id])
  end

  test 'published single choice question requires only one correct choice' do
    quiz = PracticeQuiz.create!(practice: practices(:practice1), published: false)
    question = quiz.practice_quiz_questions.build(
      question_type: :single_choice,
      body: '正しいものを選んでください。',
      position: 1,
      published: true
    )
    question.practice_quiz_choices.build(body: '正解1', correct: true, position: 1)
    question.practice_quiz_choices.build(body: '正解2', correct: true, position: 2)

    assert_not question.valid?
    assert_includes question.errors.full_messages, '単一選択の正解は1つだけにしてください。'
  end

  private

  def create_question(question_type)
    quiz = PracticeQuiz.create!(practice: practices(:practice1), published: false)
    question = quiz.practice_quiz_questions.create!(
      question_type:,
      body: '正しいものを選んでください。',
      position: 1,
      published: false
    )
    question.practice_quiz_choices.create!(body: '正解1', correct: true, position: 1)
    question.practice_quiz_choices.create!(body: '正解2', correct: question.multiple_choice?, position: 2)
    question.practice_quiz_choices.create!(body: '不正解', correct: false, position: 3)
    question.update!(published: true)
    question
  end
end
