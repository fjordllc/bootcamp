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

  test 'published question rejects duplicate nonblank choices including nested updates' do
    question = create_question(:single_choice)
    choices = question.practice_quiz_choices.to_a
    question.assign_attributes(practice_quiz_choices_attributes: [{ id: choices.last.id, body: choices.first.body }])

    assert_not question.valid?
    assert_includes question.errors.full_messages, '公開中の問題の選択肢は重複しないようにしてください。'
  end

  test 'published question ignores choice marked for deletion when checking duplicates' do
    question = create_question(:single_choice)
    duplicate = question.practice_quiz_choices.create!(body: '正解1', correct: false, position: 4)
    question.assign_attributes(practice_quiz_choices_attributes: [{ id: duplicate.id, _destroy: '1' }])

    assert question.valid?
    assert question.practice_quiz_choices.detect { |choice| choice.id == duplicate.id }.marked_for_destruction?
  end

  test 'draft question may contain duplicate choices' do
    question = create_question(:single_choice)
    question.published = false
    question.practice_quiz_choices.last.body = question.practice_quiz_choices.first.body

    assert question.valid?
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
