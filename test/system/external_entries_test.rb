# frozen_string_literal: true

require 'application_system_test_case'

class ExternalEntriesTest < ApplicationSystemTestCase
  test 'show listing articles' do
    visit_with_auth external_entries_url, 'komagata'
    assert_text 'ブログ'
    assert_no_text '<h2 id="結論">結論</h2>'
    assert_text '結論 この拡張機能を使おう！'
    assert_selector '.card-list-item'
  end

  test 'fetch and save rss feeds' do
    assert_difference 'ExternalEntry.count', 26 do
      VCR.use_cassette 'external_entry/fetch2', vcr_options do
        VCR.use_cassette 'external_entry/fetch' do
          mock_env('TOKEN' => 'token') do
            visit scheduler_daily_fetch_external_entry_path(token: 'token')
          end
        end
      end
    end
  end

  test 'does not show "New Report" button on External Entries page' do
    visit_with_auth external_entries_url, 'komagata'
    assert_no_link '日報作成'
    assert_no_selector 'a.btn', text: '日報作成'
  end

  test 'does not show "New Report" button on External Entries page for general user' do
    visit_with_auth external_entries_url, 'muryou'
    assert_no_link '日報作成'
    assert_no_selector 'a.btn', text: '日報作成'
  end
end
