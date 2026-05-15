# frozen_string_literal: true

class AddEmbeddingToSearchableTables < ActiveRecord::Migration[8.1]
  # CorrectAnswer is STI of Answer, so it shares the answers table
  # User, Movie, Talk include Searchable but don't need embedding
  TABLES = %i[
    practices reports products pages questions announcements
    events regular_events answers comments
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :embedding, :vector, limit: 1536
    end
  end
end
