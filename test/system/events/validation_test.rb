# frozen_string_literal: true

require 'application_system_test_case'

module Events
  class ValidationTest < ApplicationSystemTestCase
    test 'cannot create a new event when start_at > end_at' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: 'イベント開始日時 > イベント終了日時のイベント'
        fill_in 'event[description]', with: 'エラーになる'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 12:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 10:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-05 10:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-09 23:59')
        click_button 'イベントを公開'
      end
      assert_text 'イベント終了日時はイベント開始日時よりも後の日時にしてください。'
    end

    test 'cannot create a new event when open_start_at > open_end_at' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '募集開始日時 > 募集終了日時のイベント'
        fill_in 'event[description]', with: 'エラーになる'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-09 10:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-07 10:00')
        click_button 'イベントを公開'
      end
      assert_text '募集終了日時は募集開始日時よりも後の日時にしてください。'
    end

    test 'cannot create a new event when open_start_at > start_at' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '募集開始日時 > イベント開始日時のイベント'
        fill_in 'event[description]', with: 'エラーになる'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-10 10:30')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-10 11:30')
        click_button 'イベントを公開'
      end
      assert_text '募集開始日時はイベント開始日時よりも前の日時にしてください。'
    end

    test 'cannot create a new event when open_end_at > end_at' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '募集終了日時 > イベント終了日時のイベント'
        fill_in 'event[description]', with: 'エラーになる'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-05 10:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-11 12:00')
        click_button 'イベントを公開'
      end
      assert_text '募集終了日時はイベント終了日時よりも前の日時にしてください。'
    end

    test 'does not open when open_start_at > current time' do
      visit_with_auth event_path(events(:event4)), 'kimura'
      assert_text '募集開始までお待ち下さい'
    end

    test 'show participation link during opening' do
      visit_with_auth event_path(events(:event2)), 'kimura'
      assert_link '参加申込'
    end

    test 'are closed when current time > open_end_at' do
      visit_with_auth event_path(events(:event5)), 'kimura'
      assert_text '募集受付は終了しました。'
    end

    test 'show message about ending event after event end' do
      visit_with_auth event_path(events(:event6)), 'kimura'
      assert_text 'このイベントは終了しました。'
    end
  end
end
