# frozen_string_literal: true

require 'application_system_test_case'

class RegularEventsTest < ApplicationSystemTestCase
  setup do
    @raise_server_errors = Capybara.raise_server_errors
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
    stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'show the category of the regular event on regular events list' do
    visit_with_auth '/regular_events/new', 'komagata'
    fill_in 'regular_event[title]', with: '定期イベント・カテゴリーのテスト'
    first('.choices__inner').click
    find('#choices--js-choices-multiple-select-item-choice-1').click
    find('label', text: '主催者').click
    find('label', text: 'その他').click
    first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
    first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('木曜日')
    fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
    fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
    fill_in 'regular_event[description]', with: '定期イベント・カテゴリーのテストです'
    click_button '作成'
    assert_text '定期イベントを作成しました。'

    visit '/regular_events'

    # Wait for page to load and ensure elements are stable
    assert_selector '.card-list.a-card'

    # Use a more specific assertion to avoid stale element reference
    assert_selector '.card-list.a-card', text: 'その他'
  end

  test 'show listing not finished regular events' do
    visit_with_auth regular_events_path(target: 'not_finished'), 'kimura'
    assert_selector '.card-list.a-card .card-list-item', count: 22
  end

  test 'show listing all regular events' do
    visit_with_auth regular_events_path, 'kimura'
    assert_selector '.card-list.a-card .card-list-item', count: 25
    visit regular_events_path(page: 2)
    assert_selector '.card-list.a-card .card-list-item', count: 8
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
