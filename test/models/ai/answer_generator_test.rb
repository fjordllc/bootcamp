# frozen_string_literal: true

require 'test_helper'

module AI
  class AnswerGeneratorTest < ActiveSupport::TestCase
    test '#call' do
      secrets = Rails.application.config_for(:secrets)
      # Try both string and symbol keys for compatibility
      token = secrets.dig('open_ai', 'access_token') || secrets.dig(:open_ai, :access_token)

      skip 'OpenAI access token not configured in secrets - skipping AI answer generation test' if token.nil? || token.to_s.strip.empty?

      generator = AnswerGenerator.new(open_ai_access_token: token)

      VCR.use_cassette 'ai/answer_generator' do
        assert_equal 'テストの解答です。', generator.call('テストの質問です。')
      end
    end
  end
end
