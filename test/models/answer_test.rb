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
      created_at: Time.current - 1.week,
      updated_at: Time.current - 1.week,
      published_at: Time.current - 1.week
    )
    answer = Answer.create!(
      description: '最後の回答',
      user: answerer,
      question: question,
      created_at: Time.current - 1.week,
      updated_at: Time.current - 1.week
    )
    assert answer.certain_period_has_passed?
  end
end
