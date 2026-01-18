# frozen_string_literal: true

require 'test_helper'

module SmartSearch
  class EmbeddingGeneratorTest < ActiveSupport::TestCase
    test 'api_available? returns false when OPENAI_API_KEY is not set' do
      generator = EmbeddingGenerator.new
      assert_not generator.api_available?
    end
  end
end
