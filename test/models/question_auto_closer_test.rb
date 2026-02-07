# frozen_string_literal: true

require 'test_helper'

class QuestionAutoCloserTest < ActiveSupport::TestCase
  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間更新がありませんでした。このまま更新がなければ1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

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
      assert_equal AUTO_CLOSE_WARNING_MESSAGE, answer.description
    end
  end

  test '.close_and_select_best_answer' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    warned_at = created_at.advance(months: 1)
    system_user = users(:pjord)
    question.answers.create!(
      user: system_user,
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )

    travel_to warned_at.advance(weeks: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.close_and_select_best_answer
      end
    end

    travel_to warned_at.advance(weeks: 1) do
      assert_difference -> { question.answers.count }, 1 do
        QuestionAutoCloser.close_and_select_best_answer
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_MESSAGE, answer.description
      assert answer.is_a?(CorrectAnswer)
    end
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
      description: AUTO_CLOSE_WARNING_MESSAGE,
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

  test 'resets warning countdown when the question is updated' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '後日公開する質問',
      description: 'テスト',
      user: users(:kimura),
      wip: true,
      created_at:,
      updated_at: created_at
    )

    updated_at = created_at.advance(months: 1)
    question.update!(wip: false, updated_at:)

    travel_to updated_at do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.post_warning
      end
    end
  end

  test 'resets auto-close countdown when the question is updated' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    warned_at = created_at.advance(months: 1)
    question.answers.create!(
      user: users(:pjord),
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )
    updated_at = warned_at.advance(days: 1)
    question.update!(description: '質問内容を更新しました', updated_at:)

    travel_to warned_at.advance(weeks: 1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.close_and_select_best_answer
      end
    end
  end

  test 'resets auto-close countdown when a new answer is added' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    warned_at = created_at.advance(months: 1)
    question.answers.create!(
      user: users(:pjord),
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )
    added_at = warned_at.advance(days: 1)
    question.answers.create!(
      user: users(:komagata),
      description: '回答しました',
      created_at: added_at,
      updated_at: added_at
    )

    travel_to warned_at.advance(weeks: 1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.close_and_select_best_answer
      end
    end
  end

  test 'auto-closes questions that have been reopened after auto-closing' do
    created_at = Time.zone.local(2025, 10, 1, 0, 0, 0)
    question = Question.create!(
      title: '自動クローズテスト',
      description: 'テスト',
      user: users(:kimura),
      created_at:,
      updated_at: created_at
    )

    warned_at = created_at.advance(months: 1)
    system_user = users(:pjord)
    question.answers.create!(
      user: system_user,
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )
    closed_at = warned_at.advance(weeks: 1)
    auto_close_comment = CorrectAnswer.create!(
      question:,
      user: system_user,
      description: AUTO_CLOSE_MESSAGE,
      created_at: closed_at,
      updated_at: closed_at
    )
    reopened_at = closed_at.advance(days: 1)
    auto_close_comment.update!(type: nil, updated_at: reopened_at)
    question.answers.create!(
      user: users(:kimura),
      description: '回答を再募集します',
      created_at: reopened_at,
      updated_at: reopened_at
    )

    travel_to reopened_at.advance(months: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.post_warning
      end
    end

    again_warned_at = reopened_at.advance(months: 1)
    travel_to again_warned_at do
      assert_difference -> { question.answers.count }, 1 do
        QuestionAutoCloser.post_warning
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_WARNING_MESSAGE, answer.description
    end

    travel_to again_warned_at.advance(weeks: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        QuestionAutoCloser.close_and_select_best_answer
      end
    end

    travel_to again_warned_at.advance(weeks: 1) do
      assert_difference -> { question.answers.count }, 1 do
        QuestionAutoCloser.close_and_select_best_answer
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_MESSAGE, answer.description
      assert answer.is_a?(CorrectAnswer)
    end
  end
end
