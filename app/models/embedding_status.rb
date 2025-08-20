# frozen_string_literal: true

class EmbeddingStatus
  attr_reader :name, :total, :with_embedding, :without_embedding, :percentage, :last_updated

  def initialize(name, status_hash, total_row: false)
    @name = name
    @total = status_hash[:total]
    @with_embedding = status_hash[:with_embedding]
    @without_embedding = status_hash[:without_embedding]
    @percentage = status_hash[:percentage]
    @last_updated = status_hash[:last_updated]
    @total_row = total_row
  end

  def total_row?
    @total_row
  end
end
