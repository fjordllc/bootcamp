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
      response = Net::HTTP.get_response(uri.normalize)
      response.code.to_i
    rescue StandardError => _e
      false
    end
  end
end
