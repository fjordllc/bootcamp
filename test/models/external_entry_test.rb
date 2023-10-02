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

  test '.save_rdf_feed' do
    user = users(:hatsuno)
    rdf_item = Minitest::Mock.new
    rdf_item.expect(:link, 'https://test.com/index.rdf')
    rdf_item.expect(:title, 'test title')
    rdf_item.expect(:link, 'https://test.com/index.rdf')
    rdf_item.expect(:description, 'article description')
    rdf_item.expect(:dc_date, Time.zone.local(2022, 1, 1, 0, 0, 0))
    rdf_item.expect(:dc_date, Time.zone.local(2022, 1, 1, 0, 0, 0))

    assert ExternalEntry.save_rdf_feed(user, rdf_item, nil)
  end

  test 'save rdf feed with no article publish date' do
    user = users(:hatsuno)
    rdf_item = Minitest::Mock.new
    rdf_item.expect(:link, 'https://test.com/index.rdf')
    rdf_item.expect(:title, 'test title')
    rdf_item.expect(:link, 'https://test.com/index.rdf')
    rdf_item.expect(:description, 'article description')
    rdf_item.expect(:dc_date, nil)

    assert ExternalEntry.save_rdf_feed(user, rdf_item, nil)
  end

  test 'no exception even if all rdf elements are nil' do
    user = users(:hatsuno)
    rdf_item = Minitest::Mock.new
    rdf_item.expect(:link, nil)
    rdf_item.expect(:title, nil)
    rdf_item.expect(:link, nil)
    rdf_item.expect(:description, nil)
    rdf_item.expect(:dc_date, nil)

    assert ExternalEntry.save_rdf_feed(user, rdf_item, Time.zone.local(2023, 1, 1, 0, 0, 0).utc)
  end

  test '.save_rss_feed' do
    user = users(:hatsuno)
    rss_item = Minitest::Mock.new
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:pubDate, Time.zone.local(2022, 1, 1, 0, 0, 0))
    rss_item.expect(:pubDate, Time.zone.local(2022, 1, 1, 0, 0, 0))
    rss_item.expect(:title, 'test title')
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:description, 'article description')
    rss_item.expect(:enclosure, rss_item)
    rss_item.expect(:url, 'https://test.com/image.png')

    assert ExternalEntry.save_rss_feed(user, rss_item, nil)
  end

  test 'save rss feed with no article publish date' do
    user = users(:hatsuno)
    rss_item = Minitest::Mock.new
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:pubDate, nil)
    rss_item.expect(:title, 'test title')
    rss_item.expect(:link, 'https://test.com/rss')
    rss_item.expect(:description, 'article description')
    rss_item.expect(:enclosure, nil)

    assert ExternalEntry.save_rss_feed(user, rss_item, Time.zone.local(2023, 1, 1, 0, 0, 0).utc)
  end

  test 'no exception even if all rss elements are nil' do
    user = users(:hatsuno)
    rss_item = Minitest::Mock.new
    rss_item.expect(:link, nil)
    rss_item.expect(:pubDate, nil)
    rss_item.expect(:title, nil)
    rss_item.expect(:link, nil)
    rss_item.expect(:description, nil)
    rss_item.expect(:enclosure, nil)

    assert ExternalEntry.save_rss_feed(user, rss_item, nil)
  end

  test '.save_atom_feed' do
    user = users(:hatsuno)
    atom_item = Minitest::Mock.new
    atom_item.expect(:link, atom_item)
    atom_item.expect(:href, 'https://test.com/feed')
    atom_item.expect(:published, atom_item)
    atom_item.expect(:published, atom_item)
    atom_item.expect(:content, Time.zone.local(2022, 1, 1, 0, 0, 0))
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

    assert ExternalEntry.save_atom_feed(user, atom_item, nil)
  end

  test 'save atom feed with no article publish date' do
    user = users(:hatsuno)
    atom_item = Minitest::Mock.new
    atom_item.expect(:link, atom_item)
    atom_item.expect(:href, 'https://test.com/feed')
    atom_item.expect(:published, nil)
    atom_item.expect(:updated, nil)
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

    assert ExternalEntry.save_atom_feed(user, atom_item, Time.zone.local(2023, 1, 1, 0, 0, 0).utc)
  end

  test 'no exception even if all atom elements are nil' do
    user = users(:hatsuno)
    atom_item = Minitest::Mock.new
    atom_item.expect(:link, nil)
    atom_item.expect(:published, nil)
    atom_item.expect(:updated, nil)
    atom_item.expect(:title, nil)
    atom_item.expect(:content, nil)
    atom_item.expect(:link, nil)
    atom_item.expect(:content, nil)
    atom_item.expect(:links, nil)

    assert ExternalEntry.save_atom_feed(user, atom_item, nil)
  end

  test '.fetch_and_save_rss_feeds' do
    users = [users(:kimura), users(:hatsuno), users(:komagata)]

    assert_difference 'ExternalEntry.count', 56 do
      VCR.use_cassette 'external_entry/fetch3', vcr_options do
        VCR.use_cassette 'external_entry/fetch2', vcr_options do
          VCR.use_cassette 'external_entry/fetch' do
            ExternalEntry.fetch_and_save_rss_feeds(users)
          end
        end
      end
    end

    assert_no_difference 'ExternalEntry.count' do
      # 同じ記事は重複して保存しない
      VCR.use_cassette 'external_entry/fetch3', vcr_options do
        VCR.use_cassette 'external_entry/fetch2', vcr_options do
          VCR.use_cassette 'external_entry/fetch' do
            ExternalEntry.fetch_and_save_rss_feeds(users)
          end
        end
      end
    end
  end
end
