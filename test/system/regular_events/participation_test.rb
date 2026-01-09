# frozen_string_literal: true

require 'application_system_test_case'

module RegularEvents
  class ParticipationTest < ApplicationSystemTestCase
    setup do
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/all')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/admin')
      stub_request(:post, 'https://discord.com/api/webhooks/0123456789/mentor')
    end

    test 'create a regular event for all students and trainees' do
      visit_with_auth new_regular_event_path, 'komagata'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: '全員参加イベント'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('月曜日')
        fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
        fill_in 'regular_event[description]', with: '全員が参加するイベントです。'
        check('regular_event_all', allow_label_click: true)
      end
      click_button '作成'
      assert_text '定期イベントを作成しました。'
      assert_text '毎週月曜日'
      assert_text 'Watch中'
      assert_no_text '参加申込'
      assert_no_text '参加者'
      assert_text 'この定期イベントは全員参加のため参加登録は不要です。'

      visit_with_auth current_path, 'kensyu'
      assert_text 'Watch中'
      assert_text 'この定期イベントは全員参加のため参加登録は不要です。'
    end

    test 'mentor or admin can join regular event when they are organizer' do
      now = Time.current
      visit_with_auth new_regular_event_path, 'komagata'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: '全員参加イベント'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select(%w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日
                                                                                                                  土曜日][now.to_date.wday].to_s)
        fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
        fill_in 'regular_event[description]', with: '全員が参加するイベントです。'
        check('regular_event_all', allow_label_click: true)
      end
      click_button '作成'
      assert_text '定期イベントを作成しました。'
      assert_text "毎週#{%w[日曜日 月曜日 火曜日 水曜日 木曜日 金曜日 土曜日][now.to_date.wday]}"
      assert_text 'Watch中'
      assert_no_text '参加申込'
      assert_no_text '参加者'
      assert_text 'この定期イベントは全員参加のため参加登録は不要です。'

      travel_to Time.zone.local(now.year, now.month, now.day, 18, 0, 0) do
        visit_with_auth '/', 'komagata'
        within first('.card-list.has-scroll') do
          assert_text '全員参加イベント'
        end
      end
    end

    test 'join event user to organizers automatically' do
      visit_with_auth new_regular_event_path, 'hajime'
      within 'form[name=regular_event]' do
        fill_in 'regular_event[title]', with: 'ブルーベリー本輪読会'
        first('.choices__inner').click
        find('#choices--js-choices-multiple-select-item-choice-1').click
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__frequency select').select('毎週')
        first('.regular-event-repeat-rule').first('.regular-event-repeat-rule__day-of-the-week select').select('金曜日')
        fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
        fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
        fill_in 'regular_event[description]', with: '予習不要です'
        click_button '作成'
      end
      assert_text '定期イベントを作成しました。', wait: 10
      assert_text '毎週金曜日'
      assert_text 'Watch中'
      assert_css '.a-user-icon.is-hajime'
    end

    test 'upcoming events groups' do
      today_events_count = 6
      tomorrow_events_count = 2
      day_after_tomorrow_events_count = 4
      travel_to Time.zone.local(2017, 4, 3, 8, 0, 0) do
        visit_with_auth events_path, 'komagata'
        within('.upcoming_events_groups') do
          assert_text '近日開催のイベント'
          within('.card-list__items', text: '今日開催') do
            assert_selector('.card-list-item', count: today_events_count)
          end
          within('.card-list__items', text: '明日開催') do
            assert_selector('.card-list-item', count: tomorrow_events_count)
          end
          within('.card-list__items', text: '明後日開催') do
            assert_selector('.card-list-item', count: day_after_tomorrow_events_count)
          end
        end
      end
    end
  end
end
