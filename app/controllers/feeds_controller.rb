class FeedsController < ApplicationController
  respond_to :html, :atom
  def index
    @entries = []
    urls = User.pluck(:feed_url).reject {|f| f.blank? }
    urls.each do |url|
      begin
        @feed = Feedjira::Feed.fetch_and_parse(url)
        if @feed.respond_to?(:entries) && @feed.entries.present?
          @feed.entries.each {|e| @entries << e }
        end
      rescue
        next
      end
    end
    @entries.sort! {|a, b| b.published <=> a.published }
  end
end
