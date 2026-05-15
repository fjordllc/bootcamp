# frozen_string_literal: true

require 'test_helper'

class SmartSearch::EmbeddingGeneratorTest < ActiveSupport::TestCase
  test 'api_available? returns false when API key is not set' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    generator = SmartSearch::EmbeddingGenerator.new
    assert_not generator.api_available?
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'api_available? returns true when API key is set' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = 'test-key'

    generator = SmartSearch::EmbeddingGenerator.new
    assert generator.api_available?
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'generate returns nil when API is not available' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    generator = SmartSearch::EmbeddingGenerator.new
    result = generator.generate('test text')

    assert_nil result
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'generate returns nil for blank text' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = 'test-key'

    generator = SmartSearch::EmbeddingGenerator.new
    assert_nil generator.generate(nil)
    assert_nil generator.generate('')
    assert_nil generator.generate('   ')
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'generate_batch returns empty array when API is not available' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = nil

    generator = SmartSearch::EmbeddingGenerator.new
    result = generator.generate_batch(%w[text1 text2])

    assert_empty result
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'generate_batch returns empty array for blank input' do
    original_key = ENV['OPEN_AI_ACCESS_TOKEN']
    ENV['OPEN_AI_ACCESS_TOKEN'] = 'test-key'

    generator = SmartSearch::EmbeddingGenerator.new
    assert_empty generator.generate_batch(nil)
    assert_empty generator.generate_batch([])
  ensure
    ENV['OPEN_AI_ACCESS_TOKEN'] = original_key
  end

  test 'MODEL constant is text-embedding-3-small' do
    assert_equal 'text-embedding-3-small', SmartSearch::EmbeddingGenerator::MODEL
  end
end
