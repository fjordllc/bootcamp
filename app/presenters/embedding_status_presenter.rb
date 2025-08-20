# frozen_string_literal: true

class EmbeddingStatusPresenter
  def initialize(model_statuses)
    @statuses = build_statuses(model_statuses)
  end

  attr_reader :statuses

  def model_statuses
    @statuses[0..-2] # 最後の要素（合計）以外
  end

  def overall_status
    @statuses.last # 最後の要素（合計）
  end

  private

  def build_statuses(model_statuses)
    # モデル別の状況を作成
    model_statuses_array = model_statuses.except('overall').map do |model_name, status_hash|
      EmbeddingStatus.new(model_name, status_hash)
    end

    # 合計を最後に追加
    overall = EmbeddingStatus.new('合計', model_statuses['overall'], total_row: true)
    model_statuses_array << overall
  end
end
