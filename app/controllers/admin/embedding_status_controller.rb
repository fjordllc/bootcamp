# frozen_string_literal: true

class Admin::EmbeddingStatusController < AdminController
  def index
    @embedding_stats = fetch_embedding_stats
    @total_stats = calculate_total_stats(@embedding_stats)
  end

  private

  def fetch_embedding_stats
    SmartSearch::Configuration::EMBEDDING_MODELS.filter_map do |model_name|
      model_class = model_name.safe_constantize
      next if model_class.nil?
      next unless model_class.column_names.include?('embedding')

      total = model_class.count
      with_embedding = model_class.where.not(embedding: nil).count
      percentage = total.positive? ? (with_embedding.to_f / total * 100).round(1) : 0

      {
        model_name:,
        total:,
        with_embedding:,
        percentage:
      }
    end
  end

  def calculate_total_stats(stats)
    total = stats.sum { |s| s[:total] }
    with_embedding = stats.sum { |s| s[:with_embedding] }
    percentage = total.positive? ? (with_embedding.to_f / total * 100).round(1) : 0

    { total:, with_embedding:, percentage: }
  end
end
