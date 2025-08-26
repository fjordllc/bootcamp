# frozen_string_literal: true

require_relative 'builder'

module UnifiedSearch
  class Query
    def initialize(words:, document_type:, only_me:, current_user_id:)
      @builder = UnifiedSearch::Builder.new(
        words: Array(words),
        document_type:,
        only_me:,
        current_user_id:
      )
    end

    def page_sql(limit:, offset:)
      <<~SQL
        #{wrapped_union_sql}
        ORDER BY updated_at DESC
        LIMIT #{Integer(limit)} OFFSET #{Integer(offset)}
      SQL
    end

    def count_sql
      "SELECT COUNT(*) FROM (#{union_sql}) AS unified"
    end

    private

    def union_sql
      @builder.union_sql
    end

    def wrapped_union_sql
      "SELECT #{COLUMNS_SQL} FROM (#{union_sql}) AS unified"
    end

    COLUMNS_SQL = <<~SQL
      id, record_type, title, body, description, user_id, updated_at, wip, commentable_type, commentable_id
    SQL
  end
end
