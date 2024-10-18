# frozen_string_literal: true

module Url
  class Client
    def self.request(url)
      new(url).request
    end

    def initialize(url)
      @url = url
    end

    def request
      uri = Addressable::URI.parse(@url).normalize
      return unless valid_url?(uri)

      Net::HTTP.get_response(uri)
    end

    private

    def valid_url?(uri)
      return unless LinkChecker::Checker.valid_url?(uri)

      valid_domein?(uri.host)
    end

    def valid_domein?(domein)
      Resolv.getaddress(domein)
      true
    rescue Resolv::ResolvError
      false
    end
  end
end
