class FeedsController < ApplicationController
  respond_to :html, :atom
  def index
    @entries = []
    urls = User.pluck(:feed_url).reject {|f| f.blank? }
    @feeds = Feedzirra::Feed.fetch_and_parse(urls)
    @feeds.each do |url, feed|
      if feed.respond_to?(:entries) && feed.entries.present?
        feed.entries.each {|e| @entries << e }
      end
    end

    @entries.sort! {|a, b| b.published <=> a.published }
  end
end
