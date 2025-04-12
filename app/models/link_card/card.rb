# frozen_string_literal: true

module LinkCard
  class Card
    def initialize(url, tweet)
      @url = url
      @tweet = tweet
    end

    def metadata
      Rails.cache.fetch @url, expires_in: 3.days do
        @tweet ? fetch_tweet : Metadata.new(@url).fetch
      end
    end

    private

    def fetch_tweet
      embed_tweet_url = "https://publish.twitter.com/oembed?url=#{@url}"
      response = Link::Client.request(embed_tweet_url)
      response.message == 'OK' ? response.body : nil
    end
  end
end
