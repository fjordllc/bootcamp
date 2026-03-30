# frozen_string_literal: true

require 'test_helper'

class PjordQuestionAnswererTest < ActiveSupport::TestCase
  test 'enqueues PjordQuestionAnswerJob on call' do
    question = questions(:question1)
    answerer = PjordQuestionAnswerer.new

    assert_enqueued_with(job: PjordQuestionAnswerJob, args: [{ question_id: question.id }]) do
      answerer.call('question.create', Time.current, Time.current, 'unique_id', question: question)
    end
  end
end
