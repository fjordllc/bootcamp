# frozen_string_literal: true

module McpRateLimiting
  private

  # The endpoint-wide cap runs before the bearer-token lookup so that
  # unauthenticated traffic is also bounded; each request increments the
  # global counter exactly once, here, and never again after
  # authentication.
  def within_global_request_limit?
    window = Time.current.to_i / 60
    count = Mcp::RateLimitCounter.increment("mcp-request:global:#{window}")
    return global_limit_unavailable unless count
    return true if count <= Rails.configuration.x.mcp.global_requests_per_minute

    global_rate_limited
    false
  rescue StandardError => e
    Rails.logger.error(audit_log(
                         event: 'mcp.rate_limit',
                         result: 'unavailable',
                         exception_class: e.class.name,
                         location: safe_backtrace_location(e)
                       ))
    head :service_unavailable
    false
  end

  def global_limit_unavailable
    Rails.logger.error(audit_log(event: 'mcp.rate_limit', result: 'unavailable'))
    head :service_unavailable
    false
  end

  def global_rate_limited
    Rails.logger.info(audit_log(event: 'mcp.rate_limit', result: 'global_rate_limited'))
    response.headers['Retry-After'] = (60 - Time.current.to_i % 60).to_s
    head :too_many_requests
  end

  def request_limit_status(user_id, application_id)
    window = Time.current.to_i / 60
    count = Mcp::RateLimitCounter.increment("mcp-request:#{user_id}:#{window}")
    return :unavailable unless count

    count > Rails.configuration.x.mcp.requests_per_minute ? :limited : :allowed
  rescue StandardError => e
    Rails.logger.error(audit_log(
                         event: 'mcp.rate_limit',
                         user_id:,
                         application_id:,
                         result: 'unavailable',
                         exception_class: e.class.name,
                         location: safe_backtrace_location(e)
                       ))
    :unavailable
  end

  def rate_limit_unavailable(context)
    Rails.logger.error(audit_log(
                         event: 'mcp.rate_limit',
                         user_id: context.fetch(:user).id,
                         application_id: context.fetch(:application_id),
                         result: 'unavailable'
                       ))
    head :service_unavailable
  end

  def rate_limited(context, result: 'rate_limited')
    audit_request(
      context:,
      status: 429,
      body: '',
      started_at: Process.clock_gettime(Process::CLOCK_MONOTONIC),
      result:
    )
    response.headers['Retry-After'] = (60 - Time.current.to_i % 60).to_s
    head :too_many_requests
  rescue StandardError
    head :service_unavailable
  end
end
