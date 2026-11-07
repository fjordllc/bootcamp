# frozen_string_literal: true

require 'ipaddr'
require 'uri'

module McpOauth
  module RedirectUris
    private

    def registered_redirect_uri?(application, requested_uri)
      return false unless requested_uri.is_a?(String)

      application.redirect_uri.to_s.split.any? do |registered_uri|
        redirect_uri_matches?(registered_uri, requested_uri)
      end
    end

    def redirect_uri_matches?(registered_uri, requested_uri)
      return true if registered_uri == requested_uri

      registered = URI.parse(registered_uri)
      requested = URI.parse(requested_uri)
      return false unless loopback_http_uri?(registered) && loopback_http_uri?(requested)

      [registered.scheme, registered.host, registered.path, registered.query, registered.fragment] ==
        [requested.scheme, requested.host, requested.path, requested.query, requested.fragment]
    rescue URI::InvalidURIError
      false
    end

    def loopback_http_uri?(uri)
      return false unless uri.scheme == 'http' && uri.userinfo.nil? && uri.fragment.nil?

      uri.host == 'localhost' || IPAddr.new(uri.host).loopback?
    rescue IPAddr::Error, TypeError
      false
    end
  end
end
