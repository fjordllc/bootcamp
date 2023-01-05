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
    def parse_rss_feed(feed_url)
      return nil if feed_url.blank?

      begin
        RSS::Parser.parse(feed_url).items
      rescue OpenURI::HTTPError
        nil
      end
    end

    def save_rss_feed(user, rss_item)
      external_entry = ExternalEntry.new(
        title: rss_item.title,
        url: rss_item.link,
        summary: rss_item.description,
        thumbnail_image_url: rss_item.enclosure.url,
        published_at: rss_item.pubDate,
        user: user
      )

      external_entry.save
    end
  end
end
