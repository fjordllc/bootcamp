# frozen_string_literal: true

require 'test_helper'

class ExternalEntryTest < ActiveSupport::TestCase
  test '#thumbnail_url' do
    external_entry = external_entries(:external_entry1)
    assert_equal '/images/external_entries/thumbnails/blank.svg', external_entry.thumbnail_url
  end

  test '.parse_rss_feed' do
    blank = ''
    assert_not ExternalEntry.parse_rss_feed(blank)

    url_404_error = 'https://example.com/rss'
    assert_not ExternalEntry.parse_rss_feed(url_404_error)

    not_url_format = 'example.com/rss'
    assert_not ExternalEntry.parse_rss_feed(not_url_format)

    VCR.use_cassette 'external_entry/fetch', vcr_options do
      feed_url = 'https://example1.com/rss'
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
    users = [users(:kimura), users(:hatsuno)]

    assert_difference 'ExternalEntry.count', 26 do
      VCR.use_cassette 'external_entry/fetch2', vcr_options do
        VCR.use_cassette 'external_entry/fetch' do
          ExternalEntry.fetch_and_save_rss_feeds(users)
        end
      end
    end

    assert_no_difference 'ExternalEntry.count' do
      # 同じ記事は重複して保存しない
      VCR.use_cassette 'external_entry/fetch2', vcr_options do
        VCR.use_cassette 'external_entry/fetch' do
          ExternalEntry.fetch_and_save_rss_feeds(users)
        end
      end
    end
  end
end
