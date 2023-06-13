# frozen_string_literal: true

require 'application_system_test_case'

class EventsTest < ApplicationSystemTestCase
  test 'users except admin cannot publish a event' do
    visit_with_auth new_event_path, 'kimura'
    page.assert_no_selector("input[value='作成']")
  end

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
    assert_text '公開されるまでお待ちください。'
    assert_text 'Watch中'
  end

  test 'create a new event' do
    visit_with_auth new_event_path, 'komagata'
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
        click_button '作成'
      end
    end
    assert_text '特別イベントを作成しました。'
    assert_text 'Watch中'
  end

  test 'create copy event' do
    event = events(:event1)
    visit_with_auth event_path(event), 'komagata'
    click_link 'コピー'
    assert_text '特別イベントをコピーしました'
    within 'form[name=event]' do
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
    end
    assert_text '特別イベントを作成しました。'
    assert_text event.title
    assert_text event.location
    assert_text event.capacity
    assert_text event.description
  end

  test 'update event' do
    visit_with_auth edit_event_path(events(:event1)), 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: 'ミートアップ(修正)'
      fill_in 'event[description]', with: 'ミートアップを開催します(修正)'
      fill_in 'event[capacity]', with: 30
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.zone.parse('2019-12-21 19:00')
      fill_in 'event[end_at]', with: Time.zone.parse('2019-12-21 22:30')
      fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-11 9:00')
      fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-20 23:59')
      click_button '内容変更'
    end
    assert_text '特別イベントを更新しました。'
  end

  test 'destroy event' do
    visit_with_auth event_path(events(:event1)), 'komagata'
    find 'h2', text: 'コメント'
    find 'div.container > div.user-icons > ul.user-icons__items', visible: :all
    accept_confirm do
      click_link '削除'
    end
    assert_text '特別イベントを削除しました。'
  end

  test 'cannot create a new event when start_at > end_at' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: 'イベント開始日時 > イベント終了日時のイベント'
      fill_in 'event[description]', with: 'エラーになる'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 12:00')
      fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 10:00')
      fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-05 10:00')
      fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-09 23:59')
      click_button '作成'
    end
    assert_text 'イベント終了日時はイベント開始日時よりも後の日時にしてください。'
  end

  test 'cannot create a new event when open_start_at > open_end_at' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '募集開始日時 > 募集終了日時のイベント'
      fill_in 'event[description]', with: 'エラーになる'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
      fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
      fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-09 10:00')
      fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-07 10:00')
      click_button '作成'
    end
    assert_text '募集終了日時は募集開始日時よりも後の日時にしてください。'
  end

  test 'cannot create a new event when open_start_at > start_at' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '募集開始日時 > イベント開始日時のイベント'
      fill_in 'event[description]', with: 'エラーになる'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
      fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
      fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-10 10:30')
      fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-10 11:30')
      click_button '作成'
    end
    assert_text '募集開始日時はイベント開始日時よりも前の日時にしてください。'
  end

  test 'cannot create a new event when open_end_at > end_at' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '募集終了日時 > イベント終了日時のイベント'
      fill_in 'event[description]', with: 'エラーになる'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.zone.parse('2019-12-10 10:00')
      fill_in 'event[end_at]', with: Time.zone.parse('2019-12-10 12:00')
      fill_in 'event[open_start_at]', with: Time.zone.parse('2019-12-05 10:00')
      fill_in 'event[open_end_at]', with: Time.zone.parse('2019-12-11 12:00')
      click_button '作成'
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
    assert_text '特別イベントは終了しました。'
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
    visit_with_auth event_path(event), 'kimura'
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
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '会場にURLを含むイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: "FJORDオフィス（#{url}）"
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
    end
    within '.location' do
      assert_link url, href: url
    end
  end

  test 'participating is first-come-first-served' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '先着順のイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 20
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'kimura'
    click_link '先着順のイベント'
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[komagata kimura], participants
    end
  end

  test 'display user to waitlist when event participants are fulled' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者のいるイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'kimura'
    click_link '補欠者のいるイベント'
    accept_confirm do
      click_link '補欠登録'
    end
    assert_text '参加登録しました'
    within '.waitlist' do
      wait_user = all('img').map { |img| img['alt'] }
      assert_equal ['kimura (Kimura Tadasi)'], wait_user
    end
  end

  test 'waiting user moves up when participant cancels event' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者が繰り上がるイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'

    visit_with_auth events_path, 'kimura'
    click_link '補欠者が繰り上がるイベント'
    accept_confirm do
      click_link '補欠登録'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[komagata], participants
    end

    visit_with_auth events_path, 'komagata'
    click_link '補欠者が繰り上がるイベント'
    accept_confirm do
      click_link '参加を取り消す'
    end
    assert_text '参加を取り消しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[kimura], participants
    end
  end

  test 'does not display waitlist card when no users waiting' do
    visit_with_auth new_event_path, 'komagata'
    within 'form[name=event]' do
      fill_in 'event[title]', with: '補欠者リストが表示されないイベント'
      fill_in 'event[description]', with: 'イベントの説明文'
      fill_in 'event[capacity]', with: 1
      fill_in 'event[location]', with: 'FJORDオフィス'
      fill_in 'event[start_at]', with: Time.current.next_day
      fill_in 'event[end_at]', with: Time.current.next_day + 2.hours
      fill_in 'event[open_start_at]', with: Time.current
      fill_in 'event[open_end_at]', with: Time.current + 2.hours
      click_button '作成'
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
    assert_text 'komagata (コマガタ マサキ)'
  end

  test 'show pagination' do
    visit_with_auth '/events', 'kimura'
    assert_selector 'nav.pagination', count: 2
  end

  test 'dates of target events get filled automatically only when they are empty' do
    visit_with_auth new_event_path, 'komagata'
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

  test 'When signing up for an event during Watch, Watch is not registered twice' do
    visit_with_auth event_path(events(:event2)), 'komagata'
    find('#watch-button').click
    accept_confirm do
      click_link '参加申込'
    end
    visit_with_auth '/current_user/watches', 'komagata'
    assert_selector '.card-list-item', count: 1
  end
end
