class FeedsController < ApplicationController
  def index
    @entries = []
    urls = User.pluck(:feed_url).reject {|f| f.blank? }
    @feeds = Feedzirra::Feed.fetch_and_parse(urls)
    @feeds.each do |url, feed|
      feed.entries.each {|e| @entries << e }
    end
  end
end
