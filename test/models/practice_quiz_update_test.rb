# frozen_string_literal: true

require 'test_helper'

class PracticeQuizUpdateTest < ActiveSupport::TestCase
  setup do
    @quiz = PracticeQuiz.create!(practice: practices(:practice1), published: false)
  end

  test 'rejects malformed root and nested payloads without changing the quiz' do
    [nil, 'invalid', { published: nil }, { practice_quiz_questions_attributes: {} }].each do |attributes|
      assert_not PracticeQuizUpdate.new(@quiz, attributes).save
      assert @quiz.errors.present?
      assert_not_predicate @quiz.reload, :published?
    end
  end

  test 'publishes a complete new question together with the quiz' do
    attributes = { published: true, practice_quiz_questions_attributes: [{
      question_type: 'single_choice', body: '新しい問題', position: 1,
      practice_quiz_choices_attributes: [{ body: '正解', correct: true }, { body: '不正解', correct: false }]
    }] }

    assert PracticeQuizUpdate.new(@quiz, attributes).save
    assert_predicate @quiz.reload, :published?
    assert_predicate @quiz.practice_quiz_questions.first, :published?
    assert_equal 2, @quiz.practice_quiz_questions.first.practice_quiz_choices.count
  end

  test 'invalid resulting publication rolls back newly appended question' do
    attributes = { published: true, practice_quiz_questions_attributes: [{
      question_type: 'single_choice', body: '非公開の問題', published: false,
      practice_quiz_choices_attributes: [{ body: '正解', correct: true }, { body: '不正解', correct: false }]
    }] }

    assert_no_difference(['PracticeQuizQuestion.count', 'PracticeQuizChoice.count']) do
      assert_not PracticeQuizUpdate.new(@quiz, attributes).save
    end
    assert @quiz.errors.present?
    assert_not_predicate @quiz.reload, :published?
  end

  test 'does not assign unrelated quiz question or choice attributes' do
    attributes = { practice_id: practices(:practice2).id, practice_quiz_questions_attributes: [{
      practice_quiz_id: 0, question_type: 'single_choice', body: '問題',
      practice_quiz_choices_attributes: [{ practice_quiz_question_id: 0, body: '正解', correct: true }, { body: '不正解' }]
    }] }
    original = attributes.deep_dup

    assert PracticeQuizUpdate.new(@quiz, attributes).save

    assert_equal original, attributes
    assert_equal practices(:practice1).id, @quiz.reload.practice_id
    question = @quiz.practice_quiz_questions.first
    assert_equal @quiz.id, question.practice_quiz_id
    assert_equal [question.id], question.practice_quiz_choices.pluck(:practice_quiz_question_id).uniq
  end
end
