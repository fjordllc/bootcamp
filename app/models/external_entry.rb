# frozen_string_literal: true

class ExternalEntry < ApplicationRecord
  include ActionView::Helpers::AssetUrlHelper

  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true
  validates :published_at, presence: true

  def thumbnail_url
    thumbnail_image_url.presence || image_url('/images/external_entries/thumbnails/blank.svg')
  end

  class << self
    def fetch_and_save_rss_feeds(users)
      Parallel.each(users) do |user|
        rss_items = ExternalEntry.parse_rss_feed(user.feed_url)

        next unless rss_items

        rss_items.each do |item|
          next if ExternalEntry.find_by(url: item.link)

          ExternalEntry.save_rss_feed(user, item)
        end
      end
    end

    def parse_rss_feed(feed_url)
      return nil if feed_url.blank?

      begin
        RSS::Parser.parse(feed_url).items
      rescue OpenURI::HTTPError
        nil
      end
    end

    def save_rss_feed(user, rss_item)
      ExternalEntry.create(
        title: rss_item.title,
        url: rss_item.link,
        summary: rss_item.description,
        thumbnail_image_url: rss_item.enclosure.url,
        published_at: rss_item.pubDate,
        user: user
      )
    end
  end
end
