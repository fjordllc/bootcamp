# frozen_string_literal: true

require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  test '#certain_period_has_passed?' do
    questioner = users(:kimura)
    answerer = users(:komagata)
    question = Question.create!(
      title: '一週間前の質問',
      description: 'テスト',
      user: questioner,
      created_at: "2022-10-31",
      updated_at: "2022-10-31",
      published_at: "2022-10-31"
    )
    answer = Answer.create!(
      description: '最後の回答',
      user: answerer,
      question: question,
      created_at: "2022-10-31",
      updated_at: "2022-10-31"
    )
    travel_to Time.zone.local(2022, 11, 6, 0, 0, 0) do
      assert_not answer.certain_period_has_passed?
    end

    travel_to Time.zone.local(2022, 11, 7, 0, 0, 0) do
      assert answer.certain_period_has_passed?
    end
  end
end
