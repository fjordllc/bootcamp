# frozen_string_literal: true

module Mcp
  class PracticeTool < MCP::Tool
    private

    def success_response(data)
      text = JSON.pretty_generate(data)
      content = [{ type: 'text', text: }]
      payload = { content:, structuredContent: data }
      max_bytes = Rails.configuration.x.mcp.max_tool_response_bytes
      return error_response("The practice response exceeds the configured #{max_bytes}-byte limit.") if JSON.generate(payload).bytesize > max_bytes

      MCP::Tool::Response.new(content, structured_content: data)
    end

    def error_response(message)
      MCP::Tool::Response.new([{ type: 'text', text: message }], error: true)
    end

    def with_statement_timeout
      timeout_ms = Integer(Rails.configuration.x.mcp.statement_timeout_ms)
      ActiveRecord::Base.transaction(requires_new: true) do
        connection = ActiveRecord::Base.connection
        previous_timeout = connection.select_value("SELECT current_setting('statement_timeout')")
        connection.execute("SET LOCAL statement_timeout = #{connection.quote(timeout_ms)}")
        result = yield
        connection.execute("SET LOCAL statement_timeout = #{connection.quote(previous_timeout)}")
        result
      end
    rescue ActiveRecord::QueryCanceled
      error_response("The practice query exceeded the #{timeout_ms}ms time limit. Try again with a narrower request.")
    end

    def context_value(server_context, key)
      server_context[key] if server_context.respond_to?(:[])
    end
  end
end
