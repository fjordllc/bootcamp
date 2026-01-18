# frozen_string_literal: true

namespace :smart_search do # rubocop:disable Metrics/BlockLength
  desc 'Generate embeddings for all searchable models'
  task generate_all: :environment do
    BulkEmbeddingJob.perform_now
  end

  desc 'Generate embeddings for a specific model (e.g., rails smart_search:generate[Practice])'
  task :generate, [:model_name] => :environment do |_, args|
    model_name = args[:model_name]
    abort 'Please specify a model name' if model_name.blank?

    BulkEmbeddingJob.perform_now(model_name:)
  end

  desc 'Regenerate all embeddings (force update)'
  task regenerate_all: :environment do
    BulkEmbeddingJob.perform_now(force_regenerate: true)
  end

  desc 'Show embedding statistics'
  task stats: :environment do
    puts 'Embedding Statistics:'
    puts '-' * 50

    total_all = 0
    with_embedding_all = 0

    SmartSearch::Configuration::EMBEDDING_MODELS.each do |model_name|
      model_class = model_name.constantize
      next unless model_class.column_names.include?('embedding')

      total = model_class.count
      with_embedding = model_class.where.not(embedding: nil).count
      percentage = total.positive? ? (with_embedding.to_f / total * 100).round(1) : 0

      puts "#{model_name.ljust(20)}: #{with_embedding}/#{total} (#{percentage}%)"

      total_all += total
      with_embedding_all += with_embedding
    rescue NameError, ActiveRecord::StatementInvalid => e
      puts "#{model_name.ljust(20)}: Error - #{e.message}"
    end

    puts '-' * 50
    overall_percentage = total_all.positive? ? (with_embedding_all.to_f / total_all * 100).round(1) : 0
    puts "Total: #{with_embedding_all}/#{total_all} (#{overall_percentage}%)"
  end

  desc 'Test embedding generation with a sample text'
  task :test, [:text] => :environment do |_, args|
    text = args[:text] || 'This is a test text for embedding generation'
    generator = SmartSearch::EmbeddingGenerator.new

    abort 'Error: OPENAI_API_KEY is not configured' unless generator.api_available?

    puts "Generating embedding for: #{text.truncate(50)}"
    embedding = generator.generate(text)

    if embedding
      puts "Success! Generated embedding with #{embedding.length} dimensions"
      puts "First 5 values: #{embedding.first(5).map { |v| v.round(6) }}"
    else
      puts 'Failed to generate embedding'
    end
  end
end
