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
      @url = URI.encode(@url) # rubocop:disable Lint/UriEscapeUnescape
      uri = URI.parse(@url)
      response = Net::HTTP.get_response(uri)
      response.code.to_i
    rescue StandardError => _
      false
    end
  end
end
