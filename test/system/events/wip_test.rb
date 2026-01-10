# frozen_string_literal: true

require 'application_system_test_case'

module Events
  class WipTest < ApplicationSystemTestCase
    test 'create a new event as wip' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[title]', with: '仮のイベント'
        fill_in 'event[description]', with: 'まだWIPです。'
        fill_in 'event[capacity]', with: 20
        fill_in 'event[location]', with: 'FJORDオフィス'
        fill_in 'event[start_at]', with: Time.zone.parse('2020-10-10 10:00')
        fill_in 'event[end_at]', with: Time.zone.parse('2020-10-10 12:00')
        fill_in 'event[open_start_at]', with: Time.zone.parse('2020-10-05 10:00')
        fill_in 'event[open_end_at]', with: Time.zone.parse('2020-10-09 23:59')
      end
      assert_difference 'Event.count', 1 do
        click_button 'WIP'
        assert_text '特別イベントをWIPとして保存しました。'
      end
      assert_text '特別イベント編集'
    end

    test 'dates of target events get filled automatically only when they are empty' do
      visit_with_auth new_event_path, 'kimura'
      within 'form[name=event]' do
        fill_in 'event[start_at]', with: Time.zone.local(2050, 12, 24, 23, 59)
      end
      find('body').click
      assert_equal find('#event_end_at').value, '2050-12-24T23:59'
      assert_equal find('#event_open_end_at').value, '2050-12-24T23:59'
      within 'form[name=event]' do
        fill_in 'event[start_at]', with: Time.zone.local(2050, 12, 24, 11, 11)
      end
      find('body').click
      assert_equal find('#event_end_at').value, '2050-12-24T23:59'
      assert_equal find('#event_open_end_at').value, '2050-12-24T23:59'
    end
  end
end
