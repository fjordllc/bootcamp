# frozen_string_literal: true

require 'test_helper'

module AI
  class AnswerGeneratorTest < ActiveSupport::TestCase
    test 'call' do
      generator = AnswerGenerator.new(open_ai_access_token: ENV['OPEN_AI_ACCESS_TOKEN'])

      VCR.use_cassette 'ai/answer_generator' do
        assert_equal 'テストの解答です。', generator.call('テストの質問です。')
      end
    end
  end
end
