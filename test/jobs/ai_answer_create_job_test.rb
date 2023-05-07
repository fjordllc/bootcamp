# frozen_string_literal: true

require 'test_helper'

class AIAnswerCreateJobTest < ActiveJob::TestCase
  test '#perform' do
    question = questions(:question1)

    VCR.use_cassette 'question/ai_answer_create_job' do
      AIAnswerCreateJob.perform_now(question_id: question.id)
      assert_equal 'テストの解答です。', question.reload.ai_answer
    end
  end
end
