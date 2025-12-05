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

  test 'create regular event as WIP' do
    visit_with_auth new_regular_event_path, 'komagata'
    wait_for_regular_event_form
    # Wait for all form elements to be ready
    assert_selector 'form[name=regular_event]'
    assert_selector '.choices__inner'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: '質問相談タイム'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      find('label', text: '主催者').click
      find('label', text: '質問').click
      # Wait for select fields to be ready
      assert_selector '.regular-event-repeat-rule .regular-event-repeat-rule__frequency select'
      assert_selector '.regular-event-repeat-rule .regular-event-repeat-rule__day-of-the-week select'
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('16:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('17:00')
      fill_in 'regular_event[description]', with: '質問相談タイムです'
    end
    # Click WIP button outside of within block as it may be outside the form
    assert_difference 'RegularEvent.count', 1 do
      click_button 'WIP'
    end
    assert_text '定期イベントをWIPとして保存しました。'
    assert_text '定期イベント編集'
  end

  test 'create regular event' do
    visit_with_auth new_regular_event_path, 'komagata'
    wait_for_regular_event_form
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'チェリー本輪読会'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
      fill_in 'regular_event[description]', with: '予習不要です'
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
    assert_text '定期イベントを作成しました。'
    assert_text '毎週月曜日'
    assert_text 'Watch中'
  end

  test 'create copy regular event' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'komagata'
    click_link 'コピー'
    assert_text '定期イベントをコピーしました'
    within 'form[name=regular_event]' do
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('20:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('21:00')
      click_button '作成'
    end
    assert_text '定期イベントを作成しました。'
    assert_text regular_event.title
    assert_text regular_event.description
  end

  test 'show regular event as WIP' do
    original_count = RegularEvent.count
    visit_with_auth new_regular_event_path, 'komagata'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'WIPの定期イベント表示確認用'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      find('label', text: '主催者').click
      find('label', text: '質問').click
      fill_in 'regular_event[start_at]', with: Time.zone.parse('21:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('22:00')
      fill_in 'regular_event[description]', with: '定期イベントがWIPのときの次回開催日時の表示確認を行うための定期イベント'
      click_button 'WIP'
    end
    assert_text '定期イベントをWIPとして保存しました。', wait: 10
    assert_equal original_count + 1, RegularEvent.count

    visit_with_auth regular_event_path(RegularEvent.last), 'komagata'
    assert_equal 'WIPの定期イベント表示確認用 | FBC', title
    assert_text '毎週日曜日21:00 〜 22:00（祝日は休み）'
    assert_text 'イベント編集中のため次回開催日は未定です'
    assert_text '定期イベントがWIPのときの次回開催日時の表示確認を行うための定期イベント'
  end

  test 'update regular event' do
    visit_with_auth edit_regular_event_path(regular_events(:regular_event1)), 'komagata'
    assert_no_selector 'label', text: '定期イベント公開のお知らせを書く'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'チェリー本輪読会（修正）'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-2').click
      find('label', text: '主催者').click
      find('label', text: '輪読会').click
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('第2')
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('水曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('20:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('21:00')
      fill_in 'regular_event[description]', with: '予習不要です（修正）'
      click_button '内容変更'
    end
    assert_text '定期イベントを更新しました。'
    assert_text '第2水曜日'
  end

  test 'destroy regular event' do
    visit_with_auth regular_event_path(regular_events(:regular_event1)), 'komagata'
    find 'h2', text: 'コメント'
    find 'div.container > div.user-icons > ul.user-icons__items', visible: :all
    accept_confirm do
      find('.card-main-actions__muted-action', text: '削除').click
    end
    assert_text '定期イベントを削除しました。'
  end

  test 'edit by co-organizers' do
    visit_with_auth edit_regular_event_path(regular_events(:regular_event4)), 'hajime'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'チェリー本輪読会（修正）'
      find('label', text: '輪読会').click
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('第2')
      first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('水曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('20:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('21:00')
      fill_in 'regular_event[description]', with: '予習不要です（修正）'
      click_button '内容変更'
    end
    assert_text '定期イベントを更新しました。'
    assert_text '第2水曜日'
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
    assert_selector '.card-list.a-card .card-list-item', count: 20
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
