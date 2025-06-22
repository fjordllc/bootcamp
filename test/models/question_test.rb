# frozen_string_literal: true

require 'test_helper'
require Rails.root.join('app/models/question_auto_closer')

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

  test '.latest_update_order' do
    Question.destroy_all
    question1 = Question.create!(
      title: 'テストの質問',
      description: 'テスト',
      user: users(:kimura),
      created_at: '2022-01-01',
      updated_at: '2022-01-01'
    )
    question2 = Question.create!(
      title: 'テストの質問2',
      description: 'テスト2',
      user: users(:kimura),
      created_at: '2022-02-01',
      updated_at: '2022-02-01'
    )
    question3 = Question.create!(
      title: 'テストの質問3',
      description: 'テスト3',
      user: users(:kimura),
      created_at: '2022-01-01',
      updated_at: '2022-03-01'
    )

    assert_equal [question3, question2, question1], Question.latest_update_order
  end

  test '.by_practice_id' do
    question1 = questions(:question1)
    question2 = questions(:question2)
    question1_practice = question1.practice

    assert_includes Question.by_practice_id(question1_practice.id), question1
    assert_not_includes Question.by_practice_id(question1_practice.id), question2
  end

  test '.by_tag' do
    question_with_beginner_tag = questions(:question3)
    question_not_with_beginner_tag = questions(:question4)

    assert_includes Question.by_tag('初心者'), question_with_beginner_tag
    assert_not_includes Question.by_tag('初心者'), question_not_with_beginner_tag
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

  test '.unsolved_badge' do
    assert_equal 9, Question.unsolved_badge(
      current_user: users(:komagata),
      practice_id: practices(:practice1).id
    )

    assert_nil Question.unsolved_badge(
      current_user: users(:hatsuno),
      practice_id: practices(:practice1).id
    )
  end

  test 'generate_notice_message' do
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

  test '.post_warning' do
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at: 2.months.ago,
      updated_at: 2.months.ago
    )
    travel_to 1.month.ago + 1.day do
      assert_difference -> { question.answers.count }, 1 do
        QuestionAutoCloser.post_warning
      end
      answer = question.answers.last
      assert_equal users(:pjord), answer.user
      assert_includes answer.description, '1週間後に自動的にクローズされます'
    end
  end

  test '.close_and_select_best_answer' do
    question = Question.create!(
      title: '自動クローズテスト2',
      description: 'テスト',
      user: users(:kimura),
      created_at: 2.months.ago,
      updated_at: 2.months.ago
    )

    question.answers.create!(
      user: users(:kimura),
      description: 'これは通常のユーザーによる回答です',
      created_at: 6.weeks.ago
    )

    system_user = users(:pjord)
    question.answers.create!(
      user: system_user,
      description: 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。',
      created_at: 8.days.ago
    )

    QuestionAutoCloser.close_and_select_best_answer

    question.reload

    correct_answer = CorrectAnswer.find_by(question_id: question.id)
    assert_not_nil correct_answer
    assert_equal system_user, correct_answer.user
    assert_includes correct_answer.description, '自動的にクローズしました'
  end
end
