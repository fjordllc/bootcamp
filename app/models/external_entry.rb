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
      threads = Concurrent::Promises.future do
        users.each do |user|
          feed = ExternalEntry.parse_rss_feed(user.feed_url)

          next unless feed

          feed.items.each do |item|
            case item.class.name
            when 'RSS::Atom::Feed::Entry' then ExternalEntry.save_atom_feed(user, item, feed.channel&.dc_date)
            when 'RSS::Rss::Channel::Item' then ExternalEntry.save_rss_feed(user, item, feed.channel&.lastBuildDate)
            when 'RSS::RDF::Item' then ExternalEntry.save_rdf_feed(user, item, feed.updated&.content)
            end
          end
        end
      end

      Concurrent::Promises.zip(threads).wait!
    end

    def parse_rss_feed(feed_url)
      return nil if feed_url.blank?

      begin
        RSS::Parser.parse(feed_url)
      rescue StandardError => e
        logger.warn("[RSS Feed] #{feed_url}: #{e.message}")
        nil
      end
    end

    def save_rdf_feed(user, rdf_item, feed_updated)
      return if ExternalEntry.find_by(url: rdf_item.link)

      ExternalEntry.create(
        title: rdf_item.title,
        url: rdf_item.link,
        summary: rdf_item.description,
        thumbnail_image_url: nil,
        published_at: rdf_publish_date(rdf_item, feed_updated),
        user:
      )
    end

    def save_rss_feed(user, rss_item, feed_updated)
      return if ExternalEntry.find_by(url: rss_item.link)

      ExternalEntry.create(
        title: rss_item.title,
        url: rss_item.link,
        summary: rss_item.description,
        thumbnail_image_url: rss_item.enclosure&.url,
        published_at: rss_publish_date(rss_item, feed_updated),
        user:
      )
    end

    def save_atom_feed(user, atom_item, feed_updated)
      return if ExternalEntry.find_by(url: atom_item.link&.href)

      ExternalEntry.create(
        title: atom_item.title&.content,
        url: atom_item.link&.href,
        summary: atom_item.content&.content,
        thumbnail_image_url: atom_item.links&.find { |link| !link.type.nil? && link.type.include?('image') }&.href,
        published_at: atom_publish_date(atom_item, feed_updated),
        user:
      )
    end

    private

    def rdf_publish_date(rdf_item, feed_updated)
      return rdf_item.dc_date if rdf_item.dc_date
      return feed_updated if feed_updated

      Time.zone.today
    end

    def rss_publish_date(rss_item, feed_updated)
      return rss_item.pubDate if rss_item.pubDate
      return feed_updated if feed_updated

      Time.zone.today
    end

    def atom_publish_date(atom_item, feed_updated)
      return atom_item.published.content if atom_item.published
      return atom_item.updated.content if atom_item.updated
      return feed_updated if feed_updated

      Time.zone.today
    end
  end
end
