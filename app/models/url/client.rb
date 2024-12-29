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
      return unless LinkChecker::Checker.valid_url?(uri)

      Net::HTTP.get_response(uri)
    end
  end
end
