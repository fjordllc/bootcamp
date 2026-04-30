# frozen_string_literal: true

require 'net/http'

module LinkFetcher
  module Fetcher
    class TooManyRedirects < StandardError; end

    FETCH_ERRORS = [
      SocketError,
      Errno::ECONNREFUSED,
      Errno::EHOSTUNREACH,
      Errno::ETIMEDOUT,
      Net::OpenTimeout,
      Net::ReadTimeout,
      EOFError,
      OpenSSL::SSL::SSLError
    ].freeze

    DEFAULT_TIMEOUT = 5
    DEFAULT_REDIRECT_LIMIT = 5

    module_function

    def fetch(url, redirect_limit = DEFAULT_REDIRECT_LIMIT)
      raise TooManyRedirects if redirect_limit.negative?
      return nil unless LinkChecker::Checker.valid_url?(url)

      uri = Addressable::URI.parse(url).normalize
      safe_ips = SafeIpResolver.resolve_ips(uri)
      return nil if safe_ips.nil?

      http = build_http(uri, safe_ips)
      response = http.request_get(uri.request_uri)

      if response.is_a?(Net::HTTPRedirection)
        redirect_url = build_redirect_url(url, response)
        return nil unless redirect_url

        fetch(redirect_url, redirect_limit - 1)
      else
        response
      end
    rescue TooManyRedirects => e
      Rails.logger.info("[LinkFetcher] #{e.class}: #{uri.host}")
      nil
    rescue *FETCH_ERRORS => e
      Rails.logger.warn("[LinkFetcher] #{e.class}: #{e.message}")
      nil
    end

    def build_http(uri, ips)
      http = Net::HTTP.new(uri.host, uri.inferred_port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      end
      http.open_timeout = DEFAULT_TIMEOUT
      http.read_timeout = DEFAULT_TIMEOUT
      http.response_body_encoding = true
      http.ipaddr = ips.first
      http
    end

    def build_redirect_url(url, response)
      location = response['location']
      return nil if location.blank?

      URI.join(url, location).to_s
    rescue URI::InvalidURIError
      nil
    end
  end
end
