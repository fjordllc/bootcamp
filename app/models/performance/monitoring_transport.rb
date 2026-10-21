# frozen_string_literal: true

require 'googleauth'
require 'net/http'
require 'timeout'

module Performance
  class MonitoringTransport
    class Error < StandardError
      attr_reader :state

      def initialize(state)
        @state = state
        super(state.to_s)
      end
    end
    SCOPE = 'https://www.googleapis.com/auth/monitoring.read'

    def initialize(auth: nil, http: Net::HTTP, budget: 12, auth_budget: 2)
      @auth = auth || -> { Google::Auth.get_application_default([SCOPE]).fetch_access_token!['access_token'] }
      @http = http
      @deadline = clock + budget
      @auth_budget = auth_budget
      @calls = 0
      @bytes = 0
    end

    def get(path, params)
      @calls += 1
      raise Error, :partial if @calls > 15

      token = access_token
      uri = URI::HTTPS.build(host: 'monitoring.googleapis.com', path:, query: URI.encode_www_form(params))
      request = Net::HTTP::Get.new(uri)
      request['Authorization'] = "Bearer #{token}"
      request['Accept-Encoding'] = 'identity'
      Timeout.timeout(remaining) { JSON.parse(perform(uri, request)) }
    rescue Timeout::Error
      raise Error, :timeout
    rescue JSON::ParserError, EncodingError
      raise Error, :invalid_schema
    rescue SocketError, IOError, SystemCallError, OpenSSL::SSL::SSLError
      raise Error, :unavailable
    end

    private

    def access_token
      @token ||= Timeout.timeout([@auth_budget, remaining].min) { @auth.call }
      raise Error, :credential_error unless @token.is_a?(String) && @token.present?

      @token
    rescue Timeout::Error
      raise Error, :credential_error
    rescue Google::Auth::Error, Signet::AuthorizationError
      raise Error, :credential_error
    end

    def perform(uri, request)
      connection = @http.new(uri.host, 443)
      connection.use_ssl = true
      connection.verify_mode = OpenSSL::SSL::VERIFY_PEER
      connection.open_timeout = [1, remaining].min
      connection.read_timeout = connection.write_timeout = [2, remaining].min
      connection.max_retries = 0
      body = +''
      connection.request(request) do |response|
        validate_status(response.code.to_i)
        response.read_body do |chunk|
          @bytes += chunk.bytesize
          raise Error, :partial if body.bytesize + chunk.bytesize > 4.megabytes || @bytes > 16.megabytes

          body << chunk
        end
      end
      body
    end

    def validate_status(status)
      return if status == 200

      raise Error, { 401 => :credential_error, 403 => :permission_error, 404 => :missing_metric }.fetch(status, :unavailable)
    end

    def remaining
      value = @deadline - clock
      raise Error, :timeout unless value.positive?

      value
    end

    def clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
