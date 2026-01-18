# frozen_string_literal: true

namespace :smart_search do # rubocop:disable Metrics/BlockLength
  desc 'Generate embeddings for all records without embeddings'
  task generate_all: :environment do
    puts 'Starting embedding generation for all models...'
    BulkEmbeddingJob.perform_now
    puts 'Completed.'
  end

  desc 'Generate embeddings for a specific model'
  task :generate, [:model_name] => :environment do |_task, args|
    model_name = args[:model_name]
    abort 'Usage: rails smart_search:generate[ModelName]' if model_name.blank?

    puts "Generating embeddings for #{model_name}..."
    BulkEmbeddingJob.perform_now(model_name:)
    puts 'Completed.'
  end

  desc 'Regenerate all embeddings (force update)'
  task regenerate_all: :environment do
    puts 'Regenerating all embeddings...'
    BulkEmbeddingJob.perform_now(force_regenerate: true)
    puts 'Completed.'
  end

  desc 'Show embedding statistics'
  task stats: :environment do
    puts "\n=== Embedding Statistics ==="
    total_all = 0
    with_embedding_all = 0

    SmartSearch::Configuration::EMBEDDING_MODELS.each do |model_name|
      model_class = model_name.constantize
      total = model_class.count
      with_embedding = model_class.where.not(embedding: nil).count
      percentage = total.positive? ? (with_embedding.to_f / total * 100).round(1) : 0

      puts "#{model_name.ljust(20)}: #{with_embedding}/#{total} (#{percentage}%)"

      total_all += total
      with_embedding_all += with_embedding
    end

    overall = total_all.positive? ? (with_embedding_all.to_f / total_all * 100).round(1) : 0
    puts '-' * 40
    puts "#{'Total'.ljust(20)}: #{with_embedding_all}/#{total_all} (#{overall}%)"
  end

  desc 'Test embedding generation'
  task :test, [:text] => :environment do |_task, args|
    text = args[:text] || 'Rubyプログラミングの基礎を学ぶ'

    generator = SmartSearch::EmbeddingGenerator.new

    puts "API Available: #{generator.api_available?}"
    puts "Test text: #{text}"

    if generator.api_available?
      embedding = generator.generate(text)
      if embedding
        puts 'Embedding generated successfully'
        puts "Dimensions: #{embedding.length}"
        puts "Sample values: #{embedding.first(5).map { |v| v.round(4) }}"
      else
        puts 'Failed to generate embedding'
      end
    else
      puts 'API key not configured. Set OPENAI_API_KEY environment variable.'
    end
  end
end
