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
      question: question,
      created_at: '2022-11-01',
      updated_at: '2022-11-01'
    )

    last_answer = Answer.create!(
      description: '最後の回答',
      user: answerer,
      question: question,
      created_at: '2022-11-02',
      updated_at: '2022-11-02'
    )

    first_answer.update!(updated_at: '2022-11-03')

    travel_to Time.zone.local(2022, 11, 4, 0, 0, 0) do
      assert_not_equal question.last_answer, first_answer
      assert_equal question.last_answer, last_answer
    end
  end
end
