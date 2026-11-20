# frozen_string_literal: true

require 'browserless_system_test_case'

class ExternalEntriesBrowserlessTest < BrowserlessSystemTestCase
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
end
