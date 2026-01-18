# frozen_string_literal: true

require 'test_helper'

module SmartSearch
  class EmbeddingGeneratorTest < ActiveSupport::TestCase
    test 'api_available? returns false when OPENAI_API_KEY is not set' do
      generator = EmbeddingGenerator.new
      assert_not generator.api_available?
    end

    test 'generate returns nil when API is not available' do
      generator = EmbeddingGenerator.new
      result = generator.generate('test text')
      assert_nil result
    end

    test 'generate returns nil for blank text' do
      generator = EmbeddingGenerator.new
      assert_nil generator.generate('')
      assert_nil generator.generate(nil)
      assert_nil generator.generate('   ')
    end

    test 'generate_batch returns empty array when API is not available' do
      generator = EmbeddingGenerator.new
      result = generator.generate_batch(%w[text1 text2])
      assert_empty result
    end

    test 'generate_batch returns empty array for blank texts' do
      generator = EmbeddingGenerator.new
      assert_empty generator.generate_batch([])
      assert_empty generator.generate_batch(nil)
    end
  end
end
