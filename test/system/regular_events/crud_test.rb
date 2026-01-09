# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class CrudTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
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
      end
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
        assert_text '定期イベントを作成しました。'
      end
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
  end
end
