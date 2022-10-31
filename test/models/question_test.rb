# frozen_string_literal: true

require 'test_helper'

class QuestionTest < ActiveSupport::TestCase
  test '#last_answer' do
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
    first_answer = Answer.create!(
      description: '回答1',
      user: answerer,
      question: question,
      created_at: Time.current - 1.week,
      updated_at: Time.current - 1.week
    )

    last_answer = Answer.create!(
      description: '回答2',
      user: answerer,
      question: question,
      created_at: Time.current - 6.days,
      updated_at: Time.current - 6.days
    )

    first_answer.update!(updated_at: Time.current - 5.days)
    assert_equal question.last_answer, last_answer
  end
end
