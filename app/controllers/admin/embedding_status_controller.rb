# frozen_string_literal: true

class Admin::EmbeddingStatusController < AdminController
  def index
    model_statuses = generate_model_statuses
    @embedding_status_presenter = EmbeddingStatusPresenter.new(model_statuses)
  end

  private

  def generate_model_statuses
    statuses = {}
    total_records = 0
    total_with_embedding = 0

    BulkEmbeddingJob::EMBEDDING_MODELS.each do |model_name|
      model_class = model_name.constantize
      total = model_class.count
      with_embedding = model_class.where.not(embedding: nil).count
      without_embedding = total - with_embedding
      percentage = total.positive? ? (with_embedding.to_f / total * 100).round(2) : 0

      # 最新のembeddingが作成された時刻を取得
      last_updated = model_class.where.not(embedding: nil).maximum(:updated_at)

      statuses[model_name] = {
        total:,
        with_embedding:,
        without_embedding:,
        percentage:,
        last_updated:
      }

      total_records += total
      total_with_embedding += with_embedding
    end

    overall_percentage = total_records.positive? ? (total_with_embedding.to_f / total_records * 100).round(2) : 0

    statuses['overall'] = {
      total: total_records,
      with_embedding: total_with_embedding,
      without_embedding: total_records - total_with_embedding,
      percentage: overall_percentage
    }

    statuses
  end
end
