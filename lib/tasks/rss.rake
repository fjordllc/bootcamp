# frozen_string_literal: true

require 'rss'

def fetch_rss_feeds(url)
  begin
    rss_items = RSS::Parser.parse(feed_url).items
  rescue
    nil
  end
end

def create_latest_article(user, rss_item)
  return if LatestArticle.find_by(url: item.link)

  latest_article = LatestArticle.new(
    title: item.title,
    url: item.link,
    summary: item.description[0,30],
    published_at: item.pubDate,
    user: user
  )

  return unless latest_article.save

  image_url = item.enclosure.url

  return unless image_url

  latest_article.thumbnail.attach(io: URI.open(image_url), filename: File.basename(image_url))
end

namespace :rss do
  desc 'Fetch RSS feeds from feed URLs.'
  task fetch_rss_feeds: :environment do
    users = User.where(retired_on: nil)

    users.each do |user|
      rss_items = fetch_rss_feeds(user.feed_url)
      next unless rss_items

      rss_items.each do |item|
        create_latest_article(user, item)
      end
    end
  end
end
