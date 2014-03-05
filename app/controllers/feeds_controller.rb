class FeedsController < ApplicationController
  respond_to :html, :atom
  def index
    @entries = []
    urls = User.pluck(:feed_url).reject {|f| f.blank? }
    urls = ["http://dresscording.com/blog/", "https://www.facebook.com/teiyu.ueki", "http://nomnel.net/atom.xml", "http://sasa1010.hatenablog.com/feed", "http://intern-intern.tumblr.com/rss", "http://jabropt.com/atom.xml", "http://satoko.tumblr.com/rss", "http://docs.komagata.org/index.atom", "http://shigotop.hatenablog.com/feed", "http://keenjoe.hatenadiary.com/", "http://gotagotagoat.hatenablog.com/", "http://yukihr.github.io/fjord_intern/feed.xml", "http://a-few-resources.hatenablog.com/feed", "http://diskogs.hatenablog.com/feed", "http://korosuke565.hatenablog.com/feed", "http://nnaoto0606.hatenablog.com/feed", "http://smellmemory.hatenablog.com/rss", "http://okami6.hatenablog.com/feed", "http://blog.goo.ne.jp/moonycat/index.rdf"]
    @feeds = Feedzirra::Feed.fetch_and_parse(urls)
    @feeds.each do |url, feed|
      if feed.respond_to?(:entries) && feed.entries.present?
        feed.entries.each {|e| @entries << e }
      end
    end

    @entries.sort! {|a, b| b.published <=> a.published }
  end
end
