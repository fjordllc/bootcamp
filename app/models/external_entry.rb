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
          rss_items = ExternalEntry.parse_rss_feed(user.feed_url)

          next unless rss_items

          rss_items.each do |item|
            case item.class.name
            when 'RSS::Atom::Feed::Entry' then ExternalEntry.save_atom_feed(user, item)
            when 'RSS::Rss::Channel::Item' then ExternalEntry.save_rss_feed(user, item)
            when 'RSS::RDF::Item' then ExternalEntry.save_rdf_feed(user, item)
            end
          end
        end
      end

      Concurrent::Promises.zip(threads).wait!
    end

    def parse_rss_feed(feed_url)
      return nil if feed_url.blank?

      begin
        RSS::Parser.parse(feed_url).items
      rescue StandardError => e
        logger.warn("[RSS Feed] #{feed_url}: #{e.message}")
        nil
      end
    end

    def save_rdf_feed(user, rdf_item)
      return if ExternalEntry.find_by(url: rdf_item.link)

      ExternalEntry.create(
        title: rdf_item.title,
        url: rdf_item.link,
        summary: rdf_item.description,
        thumbnail_image_url: nil,
        published_at: rdf_item.dc_date,
        user:
      )
    end

    def save_rss_feed(user, rss_item)
      return if ExternalEntry.find_by(url: rss_item.link)

      ExternalEntry.create(
        title: rss_item.title,
        url: rss_item.link,
        summary: rss_item.description,
        thumbnail_image_url: rss_item.enclosure&.url,
        published_at: rss_item.pubDate,
        user:
      )
    end

    def save_atom_feed(user, atom_item)
      return if ExternalEntry.find_by(url: atom_item.link.href)

      ExternalEntry.create(
        title: atom_item.title.content,
        url: atom_item.link.href,
        summary: atom_item.content.content,
        thumbnail_image_url: atom_item.links.find { |link| !link.type.nil? && link.type.include?('image') }&.href,
        published_at: atom_item.published.content,
        user:
      )
    end
  end
end
