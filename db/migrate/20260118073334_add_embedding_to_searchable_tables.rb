# frozen_string_literal: true

class AddEmbeddingToSearchableTables < ActiveRecord::Migration[8.1]
  TABLES = %i[
    practices reports products pages questions announcements
    events regular_events answers correct_answers comments
  ].freeze

  def change
    TABLES.each do |table|
      add_column table, :embedding, :vector, limit: 1536
    end
  end
end
