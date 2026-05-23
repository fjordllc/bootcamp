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
      ['link_card', @tweet ? 'tweet' : 'metadata', @url]
    end

    def request
      return unless LinkChecker::Checker.valid_url?(@url)

      @tweet ? fetch_tweet : Metadata.new(@url).fetch
    end

    def fetch_tweet
      embed_tweet_url = "https://publish.twitter.com/oembed?url=#{@url}"
      uri = Addressable::URI.parse(embed_tweet_url).normalize
      response = Net::HTTP.get_response(uri)
      response.is_a?(Net::HTTPSuccess) ? response.body : nil
    end
  end
end
