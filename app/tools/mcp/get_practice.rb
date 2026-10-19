# frozen_string_literal: true

module Mcp
  class GetPractice < PracticeTool
    MAX_PRACTICE_ID = 2_147_483_647

    tool_name 'get_practice'
    title 'プラクティス詳細'
    description '指定したプラクティスの本文を取得します。'
    input_schema(
      type: 'object',
      properties: {
        practice_id: { type: 'integer', minimum: 1, maximum: MAX_PRACTICE_ID, description: '取得するプラクティスのID。' }
      },
      required: ['practice_id'],
      additionalProperties: false
    )
    output_schema(
      type: 'object',
      properties: {
        id: { type: 'integer' },
        title: { type: 'string' },
        summary: { type: %w[string null] },
        description: { type: %w[string null] },
        goal: { type: %w[string null] },
        updated_at: { type: %w[string null] },
        url: { type: 'string' },
        memo: { type: %w[string null] }
      },
      required: %w[id title summary description goal updated_at url],
      additionalProperties: false
    )
    annotations(read_only_hint: true, destructive_hint: false, idempotent_hint: true, open_world_hint: false)

    def self.call(practice_id: nil, server_context: nil)
      new.call(practice_id:, server_context:)
    end

    def call(practice_id: nil, server_context: nil)
      return error_response('practice_id must be a positive integer.') unless valid_practice_id?(practice_id)

      practice = Practice.find_by(id: practice_id)
      return error_response("Practice #{practice_id} was not found.") unless practice

      user = context_value(server_context, :user)
      canonical_origin = context_value(server_context, :canonical_origin).to_s
      data = PracticeSerializer.detail(practice, user:, canonical_origin:)
      success_response(data)
    end

    private

    def valid_practice_id?(practice_id)
      practice_id.instance_of?(Integer) && practice_id.between?(1, MAX_PRACTICE_ID)
    end
  end
end
