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
      feed_url = 'https://example1.com/feed'
      assert ExternalEntry.parse_rss_feed(feed_url)
    end
  end

  test '.save_rss_feed' do
    user = users(:hatsuno)
    rss_item = Minitest::Mock.new
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:title, 'test title')
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:description, 'article description')
    rss_item.expect(:enclosure, rss_item)
    rss_item.expect(:url, 'https://test.com/image.png')
    rss_item.expect(:pubDate, Time.zone.local(2022, 1, 1, 0, 0, 0))

    assert ExternalEntry.save_rss_feed(user, rss_item)
  end

  test '.save_atom_feed' do
    user = users(:hatsuno)
    atom_item = Minitest::Mock.new
    atom_item.expect(:link, atom_item)
    atom_item.expect(:href, 'https://test.com/feed')
    atom_item.expect(:title, atom_item)
    atom_item.expect(:content, 'test title')
    atom_item.expect(:link, atom_item)
    atom_item.expect(:href, 'https://test.com/feed')
    atom_item.expect(:content, atom_item)
    atom_item.expect(:content, 'article description')
    atom_item.expect(:links, atom_item)
    atom_item.expect(:find, atom_item)
    atom_item.expect(:nil?, atom_item)
    atom_item.expect(:href, 'https://test.com/image.png')
    atom_item.expect(:published, atom_item)
    atom_item.expect(:content, Time.zone.local(2022, 1, 1, 0, 0, 0))

    assert ExternalEntry.save_atom_feed(user, atom_item)
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
