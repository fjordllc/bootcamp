# frozen_string_literal: true

require 'test_helper'

class ExternalEntryTest < ActiveSupport::TestCase
  test '#thumbnail_url' do
    external_entry = external_entries(:external_entry1)
    assert_equal '/images/external_entries/thumbnails/blank.svg', external_entry.thumbnail_url
  end

  test '.parse_rss_feed' do
    feed_url = ''
    assert_not ExternalEntry.parse_rss_feed(feed_url)

    feed_url = 'https://example.com/rss'
    assert_not ExternalEntry.parse_rss_feed(feed_url)

    VCR.use_cassette 'external_entry/fetch', vcr_options do
      assert ExternalEntry.parse_rss_feed(feed_url)
    end
  end

  test '.save_rss_feed' do
    user = users(:hatsuno)
    mock = Minitest::Mock.new
    mock.expect(:title, 'test title')
    mock.expect(:link, 'https://test.com/rss')
    mock.expect(:description, 'article description')
    mock.expect(:enclosure, mock)
    mock.expect(:url, 'https://test.com/image.png')
    mock.expect(:pubDate, Time.zone.local(2022, 1, 1, 0, 0, 0))

    assert ExternalEntry.save_rss_feed(user, mock)
  end

  test '.fetch_and_save_rss_feeds' do
    before_fetch_and_save = ExternalEntry.count
    users = [users(:kimura)]

    VCR.use_cassette 'external_entry/fetch', vcr_options do
      ExternalEntry.fetch_and_save_rss_feeds(users)
    end
    assert_equal before_fetch_and_save + 1, ExternalEntry.count

    VCR.use_cassette 'external_entry/fetch', vcr_options do
      ExternalEntry.fetch_and_save_rss_feeds(users)
    end
    # 同じ記事は重複して保存しない
    assert_equal before_fetch_and_save + 1, ExternalEntry.count
  end
end
