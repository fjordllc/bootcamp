# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class AnnouncementTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    test 'redirect to /announcements/new when create a regular event with announcement checkbox checked' do
      visit_with_auth new_regular_event_path, 'komagata'

      initial_count = RegularEvent.count

      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: 'お知らせ作成チェックボックス確認用イベント'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        within('.regular-event-repeat-rule') do
          first('.regular-event-repeat-rule__frequency select').select('毎週')
          first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
        end
        fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
        fill_in 'regular_event[description]', with: 'お知らせ作成画面に遷移します'
        check '定期イベント公開のお知らせを書く', allow_label_click: true
        click_button '作成'
      end
      assert_text '定期イベントを作成しました。'
      assert_equal initial_count + 1, RegularEvent.count
      assert has_field?('announcement[title]', with: 'お知らせ作成チェックボックス確認用イベントを開催します🎉')
      created_event = RegularEvent.find_by(title: 'お知らせ作成チェックボックス確認用イベント', description: 'お知らせ作成画面に遷移します')
      within('.markdown-form__preview') do
        assert_text '毎週月曜日 (祝日は休み)'
        assert_text '19:00 〜 20:00'
        assert_text '@adminonly'
        assert_text 'お知らせ作成画面に遷移します'
        assert_selector "a[href*='regular_events/#{created_event.id}']"
      end
    end

    test 'redirect to /announcements/new when publishing a regular event from WIP with announcement checkbox checked' do
      visit_with_auth new_regular_event_path, 'komagata'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: 'WIPの定期イベント'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        within('.regular-event-repeat-rule') do
          first('.regular-event-repeat-rule__frequency select').select('毎週')
          first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
        end
        fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
        fill_in 'regular_event[description]', with: 'WIPです'
      end
      assert_difference 'RegularEvent.count', 1 do
        click_button 'WIP'
        assert_text '定期イベントをWIPとして保存しました。'
      end
      check '定期イベント公開のお知らせを書く', allow_label_click: true
      click_button '内容変更'
      assert_text '定期イベントを更新しました。'
      assert has_field?('announcement[title]', with: 'WIPの定期イベントを開催します🎉')
    end
  end
end
