# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test '#last_answer' do
    questioner = users(:kimura)
    answerer = users(:komagata)
    question = Question.create!(
      title: 'テストの質問',
      description: 'テスト',
      user: questioner,
      created_at: '2022-10-31',
      updated_at: '2022-10-31',
      published_at: '2022-10-31'
    )
    first_answer = Answer.create!(
      description: '最初の回答',
      user: answerer,
      question:,
      created_at: '2022-11-01',
      updated_at: '2022-11-01'
    )

    last_answer = Answer.create!(
      description: '最後の回答',
      user: answerer,
      question:,
      created_at: '2022-11-02',
      updated_at: '2022-11-02'
    )

    first_answer.update!(updated_at: '2022-11-03')

    travel_to Time.zone.local(2022, 11, 4, 0, 0, 0) do
      assert_not_equal question.last_answer, first_answer
      assert_equal question.last_answer, last_answer
    end
  end

  test '.by_target' do
    solved_question = questions(:question3)
    not_solved_question = questions(:question1)
    assert_includes Question.by_target('solved'), solved_question
    assert_not_includes Question.by_target('solved'), not_solved_question

    assert_includes Question.by_target('not_solved'), not_solved_question
    assert_not_includes Question.by_target('not_solved'), solved_question

    assert_includes Question.by_target(nil), solved_question
    assert_includes Question.by_target(nil), not_solved_question
  end

  test '.generate_questions_property' do
    solved_questions_property = Question.generate_questions_property('solved')
    assert_equal '解決済みのQ&A', solved_questions_property.title
    assert_equal '解決済みのQ&Aはありません。', solved_questions_property.empty_message

    not_solved_questions_property = Question.generate_questions_property('not_solved')
    assert_equal '未解決のQ&A', not_solved_questions_property.title
    assert_equal '未解決のQ&Aはありません。', not_solved_questions_property.empty_message

    all_questions_property = Question.generate_questions_property(nil)
    assert_equal '全てのQ&A', all_questions_property.title
    assert_equal 'Q&Aはありません。', all_questions_property.empty_message
  end

  test '.generate_notice_message' do
    wip_question = questions(:question_for_wip)
    assert_equal '質問をWIPとして保存しました。', wip_question.generate_notice_message(:create)
    assert_equal '質問をWIPとして保存しました。', wip_question.generate_notice_message(:update)

    published_question = Question.create!(
      title: 'テストの質問',
      description: 'テスト',
      user: users(:kimura)
    )
    assert_equal '質問を作成しました。', published_question.generate_notice_message(:create)
    assert_equal '質問を更新しました。', published_question.generate_notice_message(:update)
  end
end
