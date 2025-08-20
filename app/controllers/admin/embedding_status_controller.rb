# frozen_string_literal: true

class Admin::EmbeddingStatusController < AdminController
  def index
    model_statuses = generate_model_statuses
    @embedding_status_presenter = EmbeddingStatusPresenter.new(model_statuses)
    
    # Check if credentials are available
    generator = SmartSearch::EmbeddingGenerator.new
    @credentials_available = generator.instance_variable_get(:@credentials_available)
    
    unless @credentials_available
      flash.now[:alert] = 'Google Cloud認証情報が設定されていません。Embedding機能は利用できません。'
    end
  end

  def generate_embeddings
    model_name = params[:model_name]
    
    if model_name.blank?
      flash[:alert] = 'モデル名が指定されていません。'
    else
      BulkEmbeddingJob.perform_later(model_name: model_name, force_regenerate: params[:force_regenerate] == 'true')
      flash[:notice] = "#{model_name}のembedding生成ジョブを開始しました。"
    end
    
    redirect_to admin_embedding_status_index_path
  end

  def generate_all_embeddings
    BulkEmbeddingJob.perform_later(force_regenerate: params[:force_regenerate] == 'true')
    flash[:notice] = '全モデルのembedding生成ジョブを開始しました。'
    
    redirect_to admin_embedding_status_index_path
  end

  private

  def generate_model_statuses
    statuses = {}
    total_records = 0
    total_with_embedding = 0

    SmartSearch::Configuration::EMBEDDING_MODELS.each do |model_name|
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
