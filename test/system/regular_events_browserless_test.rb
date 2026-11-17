# frozen_string_literal: true

require 'browserless_system_test_case'

class RegularEventsBrowserlessTest < BrowserlessSystemTestCase
  setup do
    @raise_server_errors = Capybara.raise_server_errors
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_regular_event_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'edit only organizers or mentor' do
    visit_with_auth edit_regular_event_path(regular_events(:regular_event4)), 'kimura'
    assert_text '定期イベント編集'

    visit_with_auth edit_regular_event_path(regular_events(:regular_event4)), 'hajime'
    assert_text '定期イベント編集'

    visit_with_auth edit_regular_event_path(regular_events(:regular_event4)), 'machida'
    assert_text '定期イベント編集'

    Capybara.raise_server_errors = false
    visit_with_auth edit_regular_event_path(regular_events(:regular_event4)), 'kensyu'
    assert_text 'ActiveRecord::RecordNotFound'
  end
end
