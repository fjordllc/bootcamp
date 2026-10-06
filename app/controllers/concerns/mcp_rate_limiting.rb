# frozen_string_literal: true

require 'digest'

module McpRateLimiting
  private

  # The endpoint-wide cap runs before the per-user limit so that
  # unauthenticated traffic is also bounded; each request increments the
  # global counter exactly once, here, and never again after
  # authentication. Requests without an accessible bearer token must
  # first pass a stricter per-source-IP cap (see
  # #within_unauthenticated_ip_limit?) so that unauthenticated floods
  # from a single address cannot exhaust the shared global allowance.
  def within_global_request_limit?
    window = Time.current.to_i / 60
    count = Mcp::RateLimitCounter.increment("mcp-request:global:#{window}")
    return limit_unavailable unless count
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

  # Only requests without an accessible bearer token reach this check;
  # authenticated traffic is already bounded by the per-user limit and
  # must not consume this quota. It runs before the global increment so
  # rejected requests never consume the shared global allowance.
  #
  # The counter key is built from the framework-resolved,
  # trusted-proxy-aware request.remote_ip (never raw X-Forwarded-For or
  # other client-supplied headers), hashed as in DCR so client IPs are
  # not stored in cache keys. Contradictory client-supplied IP headers
  # are rejected with HTTP 400 before any counter is touched, so they
  # never consume quota: by Mcp::RequestBodyLimit when request logging
  # resolves remote_ip first, or by the IpSpoofAttackError rescue here
  # when it does not (log level above info, see #invalid_remote_ip).
  def within_unauthenticated_ip_limit?
    window = Time.current.to_i / 60
    key = "mcp-request:unauthenticated-ip:#{Digest::SHA256.hexdigest(request.remote_ip.to_s)}:#{window}"
    count = Mcp::RateLimitCounter.increment(key)
    return limit_unavailable unless count
    return true if count <= Rails.configuration.x.mcp.unauthenticated_ip_requests_per_minute

    unauthenticated_ip_rate_limited
    false
  rescue ActionDispatch::RemoteIp::IpSpoofAttackError
    invalid_remote_ip
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

  # Same client-error handling as Mcp::RequestBodyLimit for spoofed IP
  # headers: request.remote_ip raises only when nothing in the request
  # lifecycle (e.g. the info-level request log line) resolved it first,
  # so this rescue is the controller-level counterpart. The failure
  # happens before any rate-limit counter is touched: fail with 400 and
  # audit at info level instead of treating it as cache unavailability.
  def invalid_remote_ip
    Rails.logger.info(audit_log(event: 'mcp.rate_limit', result: 'invalid_remote_ip'))
    head :bad_request
    false
  end

  def limit_unavailable
    Rails.logger.error(audit_log(event: 'mcp.rate_limit', result: 'unavailable'))
    head :service_unavailable
    false
  end

  def global_rate_limited
    Rails.logger.info(audit_log(event: 'mcp.rate_limit', result: 'global_rate_limited'))
    response.headers['Retry-After'] = (60 - Time.current.to_i % 60).to_s
    head :too_many_requests
  end

  def unauthenticated_ip_rate_limited
    Rails.logger.info(audit_log(event: 'mcp.rate_limit', result: 'unauthenticated_ip_rate_limited'))
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
