# frozen_string_literal: true

require 'digest'
require 'ipaddr'
require 'uri'

module McpOauth
  class RegistrationsController < ActionController::API
    include McpAuditLogging

    MAX_REDIRECT_URIS = 10
    MAX_CLIENT_NAME_LENGTH = 120
    MAX_REGISTRATIONS_PER_MINUTE = 10
    PRACTICES_SCOPE = 'mcp:practices:read'

    def create
      return head :unsupported_media_type unless request.media_type == 'application/json'

      case registration_limit_status
      when :limited then return head :too_many_requests
      when :unavailable then return head :service_unavailable
      end

      client = registration_params
      return render json: { error: 'invalid_client_metadata' }, status: :bad_request unless client

      application = Doorkeeper::Application.create!(
        name: client.fetch(:name),
        redirect_uri: client.fetch(:redirect_uris).join(' '),
        scopes: PRACTICES_SCOPE,
        confidential: false,
        mcp_client: true
      )

      render json: registration_response(application, client), status: :created
    rescue ActionController::ParameterMissing, JSON::ParserError, ActiveRecord::RecordInvalid
      render json: { error: 'invalid_client_metadata' }, status: :bad_request
    end

    private

    def registration_params
      data = request.request_parameters
      redirect_uris = data['redirect_uris']
      name = data['client_name'].to_s.strip
      return unless valid_redirect_uris?(redirect_uris)
      return unless valid_client_name?(name)
      return unless valid_registration_options?(data)

      { name:, redirect_uris: }
    end

    def valid_redirect_uris?(redirect_uris)
      redirect_uris.is_a?(Array) && redirect_uris.any? && redirect_uris.size <= MAX_REDIRECT_URIS &&
        redirect_uris.all? { |uri| valid_redirect_uri?(uri) }
    end

    def valid_client_name?(name)
      name.present? && name.length <= MAX_CLIENT_NAME_LENGTH
    end

    def valid_registration_options?(data)
      data['token_endpoint_auth_method'] == 'none' && valid_grant_types?(data) &&
        data.fetch('response_types', ['code']) == ['code'] && valid_requested_scope?(data)
    end

    def valid_grant_types?(data)
      requested_grants = data.fetch('grant_types', ['authorization_code'])
      [['authorization_code'], %w[authorization_code refresh_token]].include?(requested_grants)
    end

    def valid_requested_scope?(data)
      !data.key?('scope') || data['scope'].to_s.split == [PRACTICES_SCOPE]
    end

    def valid_redirect_uri?(value)
      return false unless value.is_a?(String)

      uri = URI.parse(value)
      return false if uri.userinfo || uri.query || uri.fragment || uri.path.blank?

      valid_https_redirect?(uri) || loopback_http_redirect?(uri)
    rescue URI::InvalidURIError, IPAddr::Error, TypeError
      false
    end

    def valid_https_redirect?(uri)
      uri.scheme == 'https' && uri.host.present?
    end

    def loopback_http_redirect?(uri)
      uri.scheme == 'http' && host_is_loopback?(uri.host)
    end

    def host_is_loopback?(host)
      return true if host == 'localhost'

      host.is_a?(String) && IPAddr.new(host).loopback?
    end

    def registration_limit_status
      key = "mcp-oauth-dcr:#{Digest::SHA256.hexdigest(request.remote_ip)}:#{Time.current.to_i / 60}"
      count = Mcp::RateLimitCounter.increment(key)
      unless count
        Rails.logger.error(audit_log(event: 'mcp.dcr_rate_limit', result: 'unavailable'))
        return :unavailable
      end

      count > MAX_REGISTRATIONS_PER_MINUTE ? :limited : :allowed
    rescue StandardError => e
      Rails.logger.error(audit_log(
                           event: 'mcp.dcr_rate_limit',
                           result: 'unavailable',
                           exception_class: e.class.name,
                           location: safe_backtrace_location(e)
                         ))
      :unavailable
    end

    def registration_response(application, client)
      {
        client_id: application.uid,
        client_id_issued_at: application.created_at.to_i,
        client_name: client.fetch(:name),
        redirect_uris: client.fetch(:redirect_uris),
        token_endpoint_auth_method: 'none',
        grant_types: ['authorization_code'],
        response_types: ['code'],
        scope: PRACTICES_SCOPE
      }
    end
  end
end
