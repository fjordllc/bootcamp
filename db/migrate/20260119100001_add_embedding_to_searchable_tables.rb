# frozen_string_literal: true

class AddEmbeddingToSearchableTables < ActiveRecord::Migration[8.1]
  # CorrectAnswer is STI of Answer, so it shares the answers table
  # User, Movie, Talk include Searchable but don't need embedding
  TABLES = %i[
    practices reports products pages questions announcements
    events regular_events answers comments
  ].freeze

  def change
    # pgvectorが利用不可の環境（テスト用SQLite等）ではスキップ
    return unless vector_extension_available?

    TABLES.each do |table|
      add_column table, :embedding, :vector, limit: 1536
    end
  end

  private

  def vector_extension_available?
    # 前のマイグレーションで有効化されていなければ、ここで試みる
    execute("CREATE EXTENSION IF NOT EXISTS vector")
    true
  rescue ActiveRecord::StatementInvalid
    false
  end
end
