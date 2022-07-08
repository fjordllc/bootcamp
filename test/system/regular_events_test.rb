# frozen_string_literal: true

require 'application_system_test_case'

class RegularEventsTest < ApplicationSystemTestCase
  test 'create regular event as WIP' do
    visit_with_auth new_regular_event_path, 'komagata'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: '質問相談タイム'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      fill_in 'regular_event[start_at]', with: Time.zone.parse('16:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('17:00')
      fill_in 'regular_event[description]', with: '質問相談タイムです'
      assert_difference 'RegularEvent.count', 1 do
        click_button 'WIP'
      end
    end
    assert_text '定期イベントをWIPとして保存しました。'
  end

  test 'create regular event' do
    visit_with_auth new_regular_event_path, 'komagata'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'チェリー本輪読会'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__frequency select')[0].select('毎週')
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__day-of-the-week select')[0].select('月曜日')
      fill_in 'regular_event[start_at]', with: Time.zone.parse('19:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('20:00')
      fill_in 'regular_event[description]', with: '予習不要です'
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
    assert_text '定期イベントを作成しました。'
    assert_text '毎週月曜日'
  end

  test 'create copy regular event' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'komagata'
    click_link 'コピー'
    assert_text '定期イベントをコピーしました'
    within 'form[name=regular_event]' do
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__frequency select')[0].select('毎週')
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__day-of-the-week select')[0].select('月曜日')
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
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: 'チェリー本輪読会（修正）'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-2').click
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__frequency select')[0].select('第2')
      first('.regular-event-repeat-rule').all('.regular-event-repeat-rule__day-of-the-week select')[0].select('水曜日')
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
    accept_confirm do
      click_link '削除'
    end
    assert_text '定期イベントを削除しました。'
  end
end
