# frozen_string_literal: true

require 'application_system_test_case'

module Events
  class CrudTest < ApplicationSystemTestCase
    test 'create a new event' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '新しいイベント'
        fill_in 'event[description]', with: 'イベントの説明文'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-05 10:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-09 23:59')
      end
      assert_difference 'Event.count', 1 do
        click_button 'イベントを公開'
        assert_text '特別イベントを作成しました。'
      end
      assert_text 'Watch中'
    end

    test 'create copy event' do
      event = events(:event1)
      visit_with_auth event_path(event), 'kimura'
      click_link '複製'
      assert_text '特別イベントを複製しました'
      within 'form[name=event]' do
        fill_in 'event[start_at]', with: Time.current.next_day
        fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
        fill_in 'event[open_end_at]', with: Time.current + 2.hours
        click_button 'イベントを公開'
      end
      assert_text '特別イベントを作成しました。'
      assert_text event.title
      assert_text event.location
      assert_text event.capacity
      assert_text event.description
    end

    test 'update event' do
      visit_with_auth edit_event_path(events(:event1)), 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: 'ミートアップ(修正)'
        fill_in 'event[description]', with: 'ミートアップを開催します(修正)'
        fill_in 'event[capacity]', with: 30
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-21 19:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-21 22:30')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-11 9:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-20 23:59')
        click_button '内容を更新'
      end
      assert_text '特別イベントを更新しました。'
    end

    test 'destroy event' do
      visit_with_auth event_path(events(:event1)), 'kimura'
      find 'h2', text: 'コメント'
      find 'div.container > div.user-icons > ul.user-icons__items', visible: :all
      accept_confirm do
        click_link '削除'
      end
      assert_text '特別イベントを削除しました。'
    end

    test 'autolink location when url is included' do
      url = 'https://bootcamp.fjord.jp/'
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '会場にURLを含むイベント'
        fill_in 'event[description]', with: 'イベントの説明文'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: "FJORDオフィス（#{url}）"
        fill_in 'event[start_at]', with: Time.current.next_day
        fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
        fill_in 'event[open_start_at]', with: Time.current
        fill_in 'event[open_end_at]', with: Time.current + 2.hours
        click_button 'イベントを公開'
      end
      within '.location' do
        assert_link url, href: url
      end
    end
  end
end
