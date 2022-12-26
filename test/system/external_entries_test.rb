# frozen_string_literal: true

require 'application_system_test_case'

class ExternalEntriesTest < ApplicationSystemTestCase
  test 'show listing articles' do
    visit_with_auth external_entries_url, 'komagata'
    assert_text 'ブログ'
    assert_selector '.card-list-item'
  end

  test 'fetch and save rss feeds' do
    external_entry_count_before_daily = ExternalEntry.count
    VCR.use_cassette 'external_entry/fetch', vcr_options do
      visit_with_auth '/scheduler/daily', 'komagata'
    end
    assert_equal external_entry_count_before_daily + 1, ExternalEntry.count
  end
end
