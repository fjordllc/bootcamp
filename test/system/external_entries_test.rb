# frozen_string_literal: true

require 'application_system_test_case'

class ExternalEntriesTest < ApplicationSystemTestCase
  test 'show listing articles' do
    visit_with_auth external_entries_url, 'komagata'
    assert_text 'ブログ'
    assert_selector '.card-list-item'
  end

  test 'fetch and save rss feeds' do
    assert_difference 'ExternalEntry.count', 26 do
      VCR.use_cassette 'external_entry/fetch2', vcr_options do
        VCR.use_cassette 'external_entry/fetch' do
          visit_with_auth '/scheduler/daily/fetch_external_entry', 'komagata'
        end
      end
    end
  end
end
