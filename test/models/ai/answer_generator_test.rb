# frozen_string_literal: true

require 'test_helper'

module AI
  class AnswerGeneratorTest < ActiveSupport::TestCase
    test '#call' do
      token = Rails.application.secrets[:open_ai][:access_token]
      generator = AnswerGenerator.new(open_ai_access_token: token)

      VCR.use_cassette 'ai/answer_generator' do
        assert_equal 'テストの解答です。', generator.call('テストの質問です。')
      end
    end
  end
end
