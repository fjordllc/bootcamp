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
      created_at: '2022-10-31',
      updated_at: '2022-10-31',
      published_at: '2022-10-31'
    )
    answer = Answer.create!(
      description: '最後の回答',
      user: answerer,
      question:,
      created_at: '2022-10-31',
      updated_at: '2022-10-31'
    )
    travel_to Time.zone.local(2022, 11, 6, 0, 0, 0) do
      assert_not answer.certain_period_has_passed?
    end

    travel_to Time.zone.local(2022, 11, 7, 0, 0, 0) do
      assert answer.certain_period_has_passed?
    end
  end

  test 'search_url returns question path with anchor when question exists' do
    answer = answers(:answer1)
    expected_url = Rails.application.routes.url_helpers.question_path(answer.question, anchor: "answer_#{answer.id}")
    assert_equal expected_url, answer.search_url
  end

  test 'search_url returns questions path when question is nil' do
    answer = answers(:answer1)
    answer.question = nil
    expected_url = Rails.application.routes.url_helpers.questions_path
    assert_equal expected_url, answer.search_url
  end

  test 'search_title returns question title when question exists' do
    answer = answers(:answer1)
    assert_equal answer.question.title, answer.search_title
  end

  test 'search_title returns fallback when question is nil' do
    answer = answers(:answer1)
    answer.question = nil
    assert_equal 'Q&A回答', answer.search_title
  end
end
