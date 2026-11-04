# frozen_string_literal: true

module McpAuditLogging
  private

  def audit_request(context:, status:, body:, started_at:, result: nil)
    metadata = audit_metadata
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000).round
    user = context.fetch(:user)
    result ||= audit_result(status, body)
    Rails.logger.info(
      audit_log(
        event: 'mcp.request',
        user_id: user.id,
        application_id: context.fetch(:application_id),
        method: metadata[:method],
        tool_name: metadata[:tool_name],
        target_id: metadata[:target_id],
        result:,
        status: status.to_i,
        duration_ms:
      )
    )
  end

  def audit_result(status, body)
    return 'error' if status.to_i >= 400

    parsed = JSON.parse(body) unless body.empty?
    return 'error' if rpc_error_response?(parsed)

    'ok'
  rescue JSON::ParserError
    'invalid_response'
  end

  def rpc_error_response?(parsed)
    return false unless parsed.is_a?(Hash)

    result = parsed['result']
    parsed.key?('error') || (result.is_a?(Hash) && result['isError'] == true)
  end

  def audit_log(attributes)
    "mcp_audit #{attributes.compact.to_json}"
  end

  def report_sdk_exception(error, _context)
    Rails.logger.error(
      audit_log(
        event: 'mcp.sdk_error',
        exception_class: error.class.name,
        location: safe_backtrace_location(error)
      )
    )

    # The SDK converts exceptions raised by tools into JSON-RPC error responses,
    # so they never reach Rails' automatic exception reporting. Report them once
    # here with the same request metadata the audit log already treats as safe;
    # never the request body, tool arguments, or bearer token.
    metadata = audit_metadata
    Rollbar.error(
      error,
      request_id: request.request_id,
      mcp_method: metadata[:method],
      mcp_tool_name: metadata[:tool_name],
      mcp_target_id: metadata[:target_id]
    )
  end

  def audit_metadata
    request.env['mcp.audit_metadata'].is_a?(Hash) ? request.env['mcp.audit_metadata'] : {}
  end

  def safe_backtrace_location(error)
    error.backtrace&.first&.delete_prefix(Rails.root.to_s + File::SEPARATOR)
  end
end
