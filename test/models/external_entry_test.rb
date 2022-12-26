# frozen_string_literal: true

require 'test_helper'

class ExternalEntryTest < ActiveSupport::TestCase
  test '#thumbnail_url' do
    external_entry = external_entries(:external_entry1)
    assert_equal '/images/external_entries/thumbnails/blank.svg', external_entry.thumbnail_url
  end

  test 'parse_rss_feed' do
    feed_url = ''
    assert_not ExternalEntry.parse_rss_feed(feed_url)

    VCR.use_cassette 'external_entry/fetch', vcr_options do
      feed_url = 'https://example.com/rss'
      assert ExternalEntry.parse_rss_feed(feed_url)
    end
  end

  test 'save_rss_feed' do
    user = users(:kimura)
    mock = Minitest::Mock.new
    mock.expect(:title, 'test title')
    mock.expect(:link, 'https://example.com/rss')
    mock.expect(:description, 'article description')
    mock.expect(:enclosure, mock)
    mock.expect(:url, 'https://example.com/image.png')
    mock.expect(:pubDate, Time.zone.local(2022, 1, 1, 0, 0, 0))

    assert ExternalEntry.save_rss_feed(user, mock)
  end

  def vcr_options
    {
      record: :once,
      match_requests_on: [
        :method,
        VCR.request_matchers.uri_without_param(:source)
      ]
    }
  end
end
