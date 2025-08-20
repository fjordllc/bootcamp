# frozen_string_literal: true

namespace :smart_search do
  desc 'Generate embeddings for records without embeddings (skip existing)'
  task generate_all_embeddings: :environment do
    puts 'Starting bulk embedding generation for records without embeddings...'
    puts '📊 Progress can be monitored with: tail -f log/embedding.log'
    puts '🔍 Or filter main log with: tail -f log/development.log | grep -E "(embedding|Progress:|Completed)"'
    puts '📌 Only records with null embedding will be processed'
    puts ''
    BulkEmbeddingJob.perform_now
    puts 'Bulk embedding generation completed.'
  end

  desc 'Generate embeddings for records without embeddings (parallel, skip existing)'
  task generate_all_embeddings_parallel: :environment do
    puts 'Starting parallel bulk embedding generation for records without embeddings...'
    puts '📊 Progress can be monitored with: tail -f log/embedding.log'
    puts '🔍 Or filter main log with: tail -f log/development.log | grep -E "(embedding|Progress:|Completed)"'
    puts '⚡ Running in parallel mode - models will be processed simultaneously'
    puts '📌 Only records with null embedding will be processed'
    puts ''
    BulkEmbeddingJob.perform_now(parallel: true)
    puts 'Parallel bulk embedding generation completed.'
  end

  desc 'Generate embeddings for a specific model (skip existing)'
  task :generate_embeddings, [:model_name] => :environment do |_task, args|
    model_name = args[:model_name]

    if model_name.blank?
      puts 'Usage: rails smart_search:generate_embeddings[ModelName]'
      puts 'Available models: Practice, Report, Product, Page, Question, Announcement, Event, RegularEvent, FAQ'
      exit 1
    end

    unless SmartSearch::Configuration::SEARCHABLE_MODELS.include?(model_name)
      puts "Invalid model name: #{model_name}"
      puts "Available models: #{SmartSearch::Configuration::SEARCHABLE_MODELS.join(', ')}"
      exit 1
    end

    puts "Starting embedding generation for #{model_name} records without embeddings..."
    puts '📊 Progress can be monitored with: tail -f log/embedding.log'
    puts '📌 Only records with null embedding will be processed'
    puts ''
    BulkEmbeddingJob.perform_now(model_name:)
    puts "Embedding generation completed for #{model_name}."
  end

  desc 'Regenerate embeddings for all records (force update)'
  task regenerate_all_embeddings: :environment do
    puts 'Starting bulk embedding regeneration for all searchable models...'
    puts '📊 Progress can be monitored with: tail -f log/embedding.log'
    puts '🔍 Or filter main log with: tail -f log/development.log | grep -E "(embedding|Progress:|Completed)"'
    puts ''
    BulkEmbeddingJob.perform_now(force_regenerate: true)
    puts 'Bulk embedding regeneration completed.'
  end

  desc 'Regenerate embeddings for all records (force update, parallel)'
  task regenerate_all_embeddings_parallel: :environment do
    puts 'Starting parallel bulk embedding regeneration for all searchable models...'
    puts '📊 Progress can be monitored with: tail -f log/embedding.log'
    puts '🔍 Or filter main log with: tail -f log/development.log | grep -E "(embedding|Progress:|Completed)"'
    puts '⚡ Running in parallel mode - models will be processed simultaneously'
    puts ''
    BulkEmbeddingJob.perform_now(force_regenerate: true, parallel: true)
    puts 'Parallel bulk embedding regeneration completed.'
  end

  desc 'Show embedding statistics'
  task stats: :environment do
    puts "\n=== SmartSearch Embedding Statistics ==="

    SmartSearch::Configuration::SEARCHABLE_MODELS.each do |model_name|
      model_class = model_name.constantize
      total = model_class.count
      with_embedding = model_class.where.not(embedding: nil).count
      without_embedding = total - with_embedding

      percentage = total.positive? ? (with_embedding.to_f / total * 100).round(2) : 0

      puts "#{model_name.ljust(15)}: #{with_embedding.to_s.rjust(6)}/#{total.to_s.ljust(6)} (#{percentage.to_s.rjust(6)}%) with embeddings"
      puts "#{' ' * 15}  #{without_embedding.to_s.rjust(6)} records without embeddings" if without_embedding.positive?
    end

    puts "\n"
  end

  desc 'Test embedding generation with a sample text'
  task :test_embedding, [:text] => :environment do |_task, args|
    text = args[:text] || 'これはテスト用のサンプルテキストです。'

    puts "Testing embedding generation with text: '#{text}'"

    begin
      # 環境変数の確認
      puts "\n=== Environment Check ==="
      puts "GOOGLE_CLOUD_PROJECT: #{ENV['GOOGLE_CLOUD_PROJECT']}"
      puts "GOOGLE_APPLICATION_CREDENTIALS: #{ENV['GOOGLE_APPLICATION_CREDENTIALS']}"
      puts "GOOGLE_CREDENTIALS present: #{ENV['GOOGLE_CREDENTIALS'] ? 'Yes' : 'No'}"
      puts "GOOGLE_CLOUD_CREDENTIALS_BASE64 present: #{ENV['GOOGLE_CLOUD_CREDENTIALS_BASE64'] ? 'Yes' : 'No'}"

      # クライアント初期化テスト
      puts "\n=== Client Initialization ==="
      generator = SmartSearch::EmbeddingGenerator.new
      puts '✓ EmbeddingGenerator initialized successfully'

      # embedding生成テスト
      puts "\n=== Embedding Generation ==="
      embedding = generator.generate_embedding(text)

      if embedding
        puts '✓ Embedding generated successfully'
        puts "  Dimension: #{embedding.length}"
        puts "  Sample values: #{embedding.first(5).map { |v| v.round(4) }}"
      else
        puts '✗ Failed to generate embedding (returned nil)'
      end
    rescue StandardError => e
      puts "✗ Error occurred: #{e.class.name}"
      puts "  Message: #{e.message}"
      puts '  Backtrace:'
      puts(e.backtrace.first(10).map { |line| "    #{line}" })
    end
  end

  desc 'Test semantic search with a query'
  task :test_search, [:query] => :environment do |_task, args|
    query = args[:query] || 'Ruby プログラミング'

    puts "Testing semantic search with query: '#{query}'"

    searcher = SmartSearch::SemanticSearcher.new
    results = searcher.search(query, limit: 5)

    puts "\n=== Search Results ==="
    if results.any?
      results.each_with_index do |result, index|
        puts "#{index + 1}. [#{result.class.name}] #{result.try(:title) || result.try(:name) || 'No title'}"
        description = result.try(:description) || result.try(:body)
        if description
          truncated = description.length > 100 ? "#{description[0..100]}..." : description
          puts "   #{truncated}"
        end
        puts ''
      end
    else
      puts 'No results found.'
    end
  end
end
