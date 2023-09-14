# frozen_string_literal: true

require 'application_system_test_case'

class EventsTest < ApplicationSystemTestCase
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
      assert_difference 'Event.count', 1 do
        click_button 'WIP'
      end
    end
    assert_text '特別イベントをWIPとして保存しました。'
    assert_text '特別イベント編集'
  end

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
      assert_difference 'Event.count', 1 do
        click_button 'イベントを公開'
      end
    end
    assert_text '特別イベントを作成しました。'
    assert_text 'Watch中'
  end

  test 'create copy event' do
    event = events(:event1)
    visit_with_auth event_path(event), 'kimura'
    click_link 'コピー'
    assert_text '特別イベントをコピーしました'
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

  test 'user can participate in an event' do
    event = events(:event2)
    visit_with_auth event_path(event), 'kimura'
    assert_difference 'event.users.count', 1 do
      accept_confirm do
        click_link '参加申込'
      end
      assert_text '参加登録しました。'
    end
  end

  test 'user can cancel event' do
    event = events(:event2)
    visit_with_auth event_path(event), 'hatsuno'
    assert_difference 'event.users.count', -1 do
      accept_confirm do
        click_link '参加を取り消す'
      end
      assert_text '参加を取り消しました。'
    end
  end

  test 'user can cancel event even if deadline has passed' do
    event = events(:event5)
    visit_with_auth event_path(event), 'hatsuno'
    assert_difference 'event.users.count', -1 do
      accept_confirm do
        click_link '参加を取り消す'
      end
      assert_text '参加を取り消しました。'
    end
    assert_no_link '参加申込'
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

  test 'participating is first-come-first-served' do
    visit_with_auth new_event_path, 'kimura'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '先着順のイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'hatsuno'
    click_link '先着順のイベント'
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[kimura hatsuno], participants
    end
  end

  test 'display user to waitlist when event participants are fulled' do
    visit_with_auth new_event_path, 'kimura'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者のいるイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'hatsuno'
    click_link '補欠者のいるイベント'
    accept_confirm do
      click_link '補欠登録'
    end
    assert_text '参加登録しました'
    within '.waitlist' do
      wait_user = all('img').map { |img| img['alt'] }
      assert_equal ['hatsuno (Hatsuno Shinji)'], wait_user
    end
  end

  test 'waiting user moves up when participant cancels event' do
    visit_with_auth new_event_path, 'kimura'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者が繰り上がるイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'hatsuno'
    click_link '補欠者が繰り上がるイベント'
    accept_confirm do
      click_link '補欠登録'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[kimura], participants
    end

    visit_with_auth events_path, 'kimura'
    click_link '補欠者が繰り上がるイベント'
    accept_confirm do
      click_link '参加を取り消す'
    end
    assert_text '参加を取り消しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[hatsuno], participants
    end
  end

  test 'does not display waitlist card when no users waiting' do
    visit_with_auth new_event_path, 'kimura'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者リストが表示されないイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    assert_no_selector '.waitlist'
  end

  test 'turn on the watch when attend an event' do
    event = events(:event2)
    visit_with_auth event_path(event), 'kimura'
    accept_confirm do
      click_link '参加申込'
    end
    assert_text 'Watch中'
  end

  test 'show user name_kana next to user name' do
    event = events(:event2)
    user = event.user
    decorated_user = ActiveDecorator::Decorator.instance.decorate(user)
    visit_with_auth event_path(event), 'kimura'
    assert_text decorated_user.long_name
  end

  test 'show user full name on list page' do
    visit_with_auth '/events', 'kimura'
    assert_text 'kimura (キムラ タダシ)'
  end

  test 'show pagination' do
    visit_with_auth '/events', 'kimura'
    assert_selector 'nav.pagination', count: 2
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

  test 'using file uploading by file selection dialogue in textarea' do
    visit_with_auth new_event_path, 'komagata'
    within(:css, '.a-file-insert') do
      assert_selector 'input.file-input', visible: false
    end
    assert_equal '.file-input', find('textarea.a-text-input')['data-input']
  end

  test 'When signing up for an event during Watch, Watch is not registered twice' do
    visit_with_auth event_path(events(:event2)), 'komagata'
    find('#watch-button').click
    accept_confirm do
      click_link '参加申込'
    end

    assert_text '参加登録しています。'
    visit_with_auth '/current_user/watches', 'komagata'
    assert_selector '.card-list-item', count: 1
  end

  test 'when the create announcements checkbox is enabled, the user is redirected to the new announcement page after create a new event' do
    event = {
      title: 'チェックボックスを有効にするとお知らせ作成ページにリダイレクトする',
      description: 'お知らせ作成ページには、リダイレクト元のイベント情報が自動入力される'
    }

    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: event[:title]
      fill_in 'event[description]', with: event[:description]
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      check 'イベント公開のお知らせを書く', allow_label_click: true
      click_button 'イベントを公開'
    end

    assert_text 'イベントを作成しました'
    within 'form[name=announcement]' do
      assert has_field? 'announcement[title]', with: /#{event[:title]}/
      assert has_field? 'announcement[description]', with: /#{event[:desription]}/
    end
  end

  test 'when the create announcements checkbox is enabled, the user is redirected to the new announcement page after edit a wip event' do
    event = {
      title: 'WIP中のイベントを公開する際、チェックボックスを有効にするとお知らせ作成ページにリダイレクトする',
      description: 'お知らせ作成ページには、リダイレクト元のイベント情報が自動入力される'
    }

    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: event[:title]
      fill_in 'event[description]', with: event[:description]
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      check 'イベント公開のお知らせを書く', allow_label_click: true
      click_button 'WIP'
    end

    check 'イベント公開のお知らせを書く', allow_label_click: true
    click_button '内容を更新'

    assert_text 'イベントを更新しました'
    within 'form[name=announcement]' do
      assert has_field? 'announcement[title]', with: /#{event[:title]}/
      assert has_field? 'announcement[description]', with: /#{event[:desription]}/
    end
  end

  test 'checkboxes for creating an announcement are display the new event page' do
    visit_with_auth new_event_path, 'komagata'
    assert_selector 'label', text: 'イベント公開のお知らせを書く'
  end

  test 'checkboxes for creating an announcement are display the edit page of wip event' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: 'WIPで保存したイベントの編集画面にはチェックボックスを表示'
      fill_in 'event[description]', with: '説明文'
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'WIP'
    end

    assert_selector 'label', text: 'イベント公開のお知らせを書く'
  end

  test 'checkboxes for creating an announcement are not display the edit page of published event' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '公開したイベントの編集画面にはチェックボックスを表示しない'
      fill_in 'event[description]', with: '説明文'
      fill_in 'event[capacity]', with: 10
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button 'イベントを公開'
    end
    click_link '内容修正'
    assert_no_selector 'label', text: 'イベント公開のお知らせを書く'
  end
end
