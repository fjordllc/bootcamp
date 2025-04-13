# frozen_string_literal: true

module LinkCard
  class Card
    def initialize(url, tweet)
      @url = url
      @tweet = tweet
    end

    def metadata
      Rails.cache.fetch @url, expires_in: 3.days do
        return unless LinkChecker::Checker.valid_url?(@url)

        @tweet ? fetch_tweet : Metadata.new(@url).fetch
      end
    end

    private

    def fetch_tweet
      embed_tweet_url = "https://publish.twitter.com/oembed?url=#{@url}"
      uri = Addressable::URI.parse(embed_tweet_url).normalize
      response = Net::HTTP.get_response(uri)
      response.message == 'OK' ? response.body : nil
    end
  end
end
