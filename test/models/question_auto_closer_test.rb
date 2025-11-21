# frozen_string_literal: true

require 'test_helper'

class QuestionAutoCloserTest < ActiveSupport::TestCase
  test '.post_warning' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    travel_to created_at.advance(months: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.post_warning
      end
    end

    travel_to created_at.advance(months: 1) do
      assert_difference -> { question.answers.count }, 1 do
        QuestionAutoCloser.post_warning
      end
      answer = question.answers.last
      assert_equal users(:pjord), answer.user
      assert_equal 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。', answer.description
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

  test 'does not post warning for WIP questions' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: 'WIPの質問',
      description: 'テスト',
      user: users(:kimura),
      wip: true,
      created_at:,
      updated_at: created_at
    )

    travel_to created_at.advance(months: 1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.post_warning
      end
    end
  end

  test 'does not close WIP questions' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '公開から1ヶ月後WIPにする質問',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    warned_at = created_at.advance(months: 1)
    question.answers.create!(
      user: users(:pjord),
      description: 'このQ&Aは1ヶ月間コメントがありませんでした。1週間後に自動的にクローズされます。',
      created_at: warned_at,
      updated_at: warned_at
    )
    question.update!(wip: true, updated_at: warned_at)

    travel_to warned_at.advance(weeks: 1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.close_and_select_best_answer
      end
    end
  end
end
