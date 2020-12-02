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
      @url = encode_ja(@url)
      uri = URI.parse(@url)
      response = Net::HTTP.get_response(uri)
      response.code.to_i
    rescue StandardError => _e
      false
    end

    def encode_ja(url)
      url.split(//).map do |c|
        if c.match?(/[-_.!~*'()a-zA-Z0-9;\/\?:@&=+$,%#]/)
          c
        else
          CGI.escape(c)
        end
      end.join
    end
  end
end
