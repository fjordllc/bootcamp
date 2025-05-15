# frozen_string_literal: true

require 'application_system_test_case'

class RegularEventsTest < ApplicationSystemTestCase
  setup do
    @raise_server_errors = Capybara.raise_server_errors
  end

  teardown do
    Capybara.raise_server_errors = @raise_server_errors
  end

  test 'create regular event as WIP' do
    visit_with_auth new_regular_event_path, 'komagata'
    within 'form[name=regular_event]' do
      fill_in 'regular_event[title]', with: '質問相談タイム'
      first('.choices__inner').click
      find('#choices--js-choices-multiple-select-item-choice-1').click
      find('label', text: '主催者').click
      find('label', text: '質問').click
      fill_in 'regular_event[start_at]', with: Time.zone.parse('16:00')
      fill_in 'regular_event[end_at]', with: Time.zone.parse('17:00')
      fill_in 'regular_event[description]', with: '質問相談タイムです'
      assert_difference 'RegularEvent.count', 1 do
        click_button 'WIP'
      end
    end
    assert_text '定期イベントをWIPとして保存しました。'
    assert_text '定期イベント編集'
  end

  test 'create regular event' do
    visit_with_auth new_regular_event_path, 'komagata'
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
      assert_difference 'RegularEvent.count', 1 do
        click_button 'WIP'
      end
    end

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
    within '.card-list.a-card' do
      assert_text 'その他'
    end
  end

  test 'show participation link during opening' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'kimura'
    assert_link '参加申込'
  end

  test 'user can participate in an regular event' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'kimura'
    assert_difference 'regular_event.participants.count', 1 do
      accept_confirm do
        click_link '参加申込'
      end
      assert_text '参加登録しました。'
    end
  end

  test 'user can cancel regular event' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'hatsuno'
    assert_difference 'regular_event.participants.count', -1 do
      accept_confirm do
        click_link '参加を取り消す'
      end
      assert_text '参加を取り消しました。'
    end
  end

  test 'turn on the watch when attend an regular event' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'kimura'
    accept_confirm do
      click_link '参加申込'
    end
    assert_text 'Watch中'
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
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
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
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
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

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_regular_event_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'redirect to /announcements/new when create a regular event with announcement checkbox checked' do
    visit_with_auth new_regular_event_path, 'komagata'
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
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
    assert_text '定期イベントを作成しました。'
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
      assert_difference 'RegularEvent.count', 1 do
        click_button 'WIP'
      end
    end
    assert_text '定期イベントをWIPとして保存しました。'
    check '定期イベント公開のお知らせを書く', allow_label_click: true
    click_button '内容変更'
    assert_text '定期イベントを更新しました。'
    assert has_field?('announcement[title]', with: 'WIPの定期イベントを開催します🎉')
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
      assert_difference 'RegularEvent.count', 1 do
        click_button '作成'
      end
    end
    assert_text '定期イベントを作成しました。'
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

  test 'admin can remove others from participation' do
    regular_event = regular_events(:regular_event1)
    visit_with_auth regular_event_path(regular_event), 'komagata'
    assert_difference 'regular_event.participants.count', -1 do
      accept_confirm do
        within('.a-card.participants') do
          first('a', text: '削除する').click
        end
      end
      assert_text '参加を取り消しました。'
    end
  end
end
