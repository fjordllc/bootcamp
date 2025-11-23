# frozen_string_literal: true

require 'test_helper'

class QuestionAutoCloserTest < ActiveSupport::TestCase
  test '.post_warning' do
    question_create_date = 2.months.ago.floor

    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at: question_create_date,
      updated_at: question_create_date
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
