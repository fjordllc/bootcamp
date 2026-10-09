# frozen_string_literal: true

module LinkCard
  class Card
    def initialize(url, tweet)
      @url = url
      @tweet = tweet
    end

    def metadata
      Rails.cache.fetch cache_key, expires_in: 3.days, skip_nil: true do
        request
      end
    end

    private

    def cache_key
      ['link_card', 'v2', @tweet ? 'tweet' : 'metadata', @url]
    end

    def request
      uri = Addressable::URI.parse(@url)
      return unless uri && uri.userinfo.nil?

      uri = URI.parse(uri.normalize.to_s)
      return unless uri.is_a?(URI::HTTP) && uri.hostname.present?

      @tweet ? fetch_tweet : Metadata.new(@url).fetch
    rescue *Metadata::FETCH_ERRORS
      nil
    end

    def fetch_tweet
      uri = Addressable::URI.parse('https://publish.twitter.com/oembed')
      uri.query_values = { url: @url }
      response = ExternalContent::HttpClient.get(uri.normalize.to_s, max_body_bytes: 2.megabytes, request_timeout: 10)
      return unless response.success?

      body = response.body.to_s.dup.force_encoding(Encoding::UTF_8)
      body if body.valid_encoding?
    end
  end
end
