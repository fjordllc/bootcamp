# frozen_string_literal: true

module LinkChecker
  class Client
    def self.request(url)
      new(url).request
    end

    def initialize(url)
      @url = url
    end

    def request
      uri = Addressable::URI.parse(@url)
      return false unless uri && uri.userinfo.nil?

      response = ExternalContent::HttpClient.get(uri.normalize.to_s, max_body_bytes: 2.megabytes, request_timeout: 10)
      response.code.to_i
    rescue ExternalContent::HttpClient::ResponseTooLarge => e
      e.code && !e.code.to_i.between?(300, 399) ? e.code.to_i : false
    rescue URI::InvalidURIError, Addressable::URI::InvalidURIError, ExternalContent::HttpClient::FetchError,
           SocketError, SystemCallError, IOError,
           Timeout::Error, OpenSSL::SSL::SSLError, Net::HTTPBadResponse
      false
    end
  end
end
