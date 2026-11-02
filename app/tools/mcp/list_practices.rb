# frozen_string_literal: true

module Mcp
  class ListPractices < PracticeTool
    DEFAULT_LIMIT = 20
    MAX_LIMIT = 100
    MAX_QUERY_LENGTH = 200
    MAX_CURSOR = 2_147_483_647

    tool_name 'list_practices'
    title 'プラクティス一覧'
    description 'プラクティスをID順で検索・ページ取得します。'
    input_schema(
      type: 'object',
      properties: {
        query: { type: 'string', maxLength: MAX_QUERY_LENGTH, description: 'タイトルの部分一致検索。最大200文字。' },
        cursor: { type: 'integer', minimum: 1, maximum: MAX_CURSOR, description: '前ページのnext_cursor。指定IDより大きいIDから取得します。' },
        limit: { type: 'integer', minimum: 1, maximum: MAX_LIMIT, default: DEFAULT_LIMIT }
      },
      additionalProperties: false
    )
    output_schema(
      type: 'object',
      properties: {
        practices: {
          type: 'array',
          items: {
            type: 'object',
            properties: {
              id: { type: 'integer' },
              title: { type: 'string' },
              summary: { type: %w[string null] },
              url: { type: 'string' }
            },
            required: %w[id title summary url],
            additionalProperties: false
          }
        },
        next_cursor: { type: %w[integer null] }
      },
      required: %w[practices next_cursor],
      additionalProperties: false
    )
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(query: nil, cursor: nil, limit: DEFAULT_LIMIT, server_context: nil)
      new.call(query:, cursor:, limit:, server_context:)
    end

    def call(query: nil, cursor: nil, limit: DEFAULT_LIMIT, server_context: nil)
      validation_error = validate_arguments(query:, cursor:, limit:)
      return error_response(validation_error) if validation_error

      scope = Practice.order(:id)
      if query.present?
        escaped_query = Practice.sanitize_sql_like(query)
        scope = scope.where('title ILIKE ?', "%#{escaped_query}%")
      end
      scope = scope.where(Practice.arel_table[:id].gt(cursor)) if cursor

      records = scope.limit(limit + 1).to_a
      has_more = records.length > limit
      page = records.first(limit)
      data = {
        'practices' => page.map { |practice| PracticeSerializer.list_item(practice, canonical_origin: canonical_origin(server_context)) },
        'next_cursor' => has_more ? page.last.id : nil
      }
      success_response(data)
    end

    private

    def validate_arguments(query:, cursor:, limit:)
      return 'query must be a string no longer than 200 characters.' unless valid_query?(query)
      return 'cursor must be a positive integer.' unless valid_cursor?(cursor)
      return 'limit must be an integer between 1 and 100.' unless valid_limit?(limit)

      nil
    end

    def valid_query?(query)
      query.nil? || (query.is_a?(String) && query.length <= MAX_QUERY_LENGTH)
    end

    def valid_cursor?(cursor)
      cursor.nil? || (cursor.instance_of?(Integer) && cursor.between?(1, MAX_CURSOR))
    end

    def valid_limit?(limit)
      limit.instance_of?(Integer) && limit.between?(1, MAX_LIMIT)
    end

    def canonical_origin(server_context)
      context_value(server_context, :canonical_origin).to_s
    end
  end
end
