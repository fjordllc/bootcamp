# frozen_string_literal: true

module LinkCard
  class Card
    def initialize(params)
      @url = params[:url]
      @tweet = params[:tweet]
    end

    def metadata
      Rails.cache.fetch @url, expires_in: 3.days do
        @tweet ? fetch_tweet : Metadata.new(@url).fetch_metadata
      end
    end

    private

    def fetch_tweet
      embed_tweet_url = "https://publish.twitter.com/oembed?url=#{@url}"
      Url::Client.request(embed_tweet_url).body
    end
  end
end
