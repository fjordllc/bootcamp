# frozen_string_literal: true

require 'test_helper'
require 'supports/question_auto_closer_helper'

class QuestionAutoCloserTest < ActiveSupport::TestCase
  include QuestionAutoCloserHelper

  AUTO_CLOSE_WARNING_MESSAGE = 'このQ&Aは1ヶ月間更新がありませんでした。このまま更新がなければ1週間後に自動的にクローズされます。'
  AUTO_CLOSE_MESSAGE = '自動的にクローズしました。'

  test 'posts warning for inactive questions' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    travel_to question.created_at.advance(months: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.post_warning
      end
    end

    travel_to question.created_at.advance(months: 1) do
      assert_difference -> { question.answers.count }, 1 do
        question_auto_closer.post_warning
      end
      answer = question.answers.last
      assert_equal users(:pjord), answer.user
      assert_equal AUTO_CLOSE_WARNING_MESSAGE, answer.description
    end
  end

  test 'auto-closes inactive questions' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    warned_at = question.created_at.advance(months: 1)
    system_user = users(:pjord)
    question.answers.create!(
      user: system_user,
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )

    travel_to warned_at.advance(weeks: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.close_inactive_questions
      end
    end

    travel_to warned_at.advance(weeks: 1) do
      assert_difference -> { question.answers.count }, 1 do
        question_auto_closer.close_inactive_questions
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_MESSAGE, answer.description
      assert answer.is_a?(CorrectAnswer)
    end
  end

  test 'does not post warning for WIP questions' do
    question = create_question(wip: true)
    question_auto_closer = QuestionAutoCloser.new

    travel_to question.created_at.advance(months: 1) do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.post_warning
      end
    end
  end

  test 'does not close WIP questions' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    warned_at = question.created_at.advance(months: 1)
    question.answers.create!(
      user: users(:pjord),
      description: AUTO_CLOSE_WARNING_MESSAGE,
      created_at: warned_at,
      updated_at: warned_at
    )
    question.update!(wip: true, updated_at: warned_at)

    travel_to warned_at.advance(weeks: 1) do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.close_inactive_questions
      end
    end
  end

  test 'resets warning countdown when the question is updated' do
    question = create_question(wip: true)
    question_auto_closer = QuestionAutoCloser.new

    updated_at = question.created_at.advance(months: 1)
    question.update!(wip: false, updated_at:)

    travel_to updated_at do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.post_warning
      end
    end
  end

  test 'resets auto-close countdown when the question is updated' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    warned_at = question.created_at.advance(months: 1)
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
        question_auto_closer.close_inactive_questions
      end
    end
  end

  test 'resets auto-close countdown when a new answer is added' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    warned_at = question.created_at.advance(months: 1)
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
        question_auto_closer.close_inactive_questions
      end
    end
  end

  test 'auto-closes questions that have been reopened after auto-closing' do
    question = create_question
    question_auto_closer = QuestionAutoCloser.new

    warned_at = question.created_at.advance(months: 1)
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
        question_auto_closer.post_warning
      end
    end

    again_warned_at = reopened_at.advance(months: 1)
    travel_to again_warned_at do
      assert_difference -> { question.answers.count }, 1 do
        question_auto_closer.post_warning
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_WARNING_MESSAGE, answer.description
    end

    travel_to again_warned_at.advance(weeks: 1, days: -1) do
      assert_no_difference -> { question.answers.count } do
        question_auto_closer.close_inactive_questions
      end
    end

    travel_to again_warned_at.advance(weeks: 1) do
      assert_difference -> { question.answers.count }, 1 do
        question_auto_closer.close_inactive_questions
      end
      answer = question.answers.last
      assert_equal system_user, answer.user
      assert_equal AUTO_CLOSE_MESSAGE, answer.description
      assert answer.is_a?(CorrectAnswer)
    end
  end
end
