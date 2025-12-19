# frozen_string_literal: true

require 'application_system_test_case'

class Events::ParticipationTest < ApplicationSystemTestCase
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
    within 'ul.card-list' do
      click_link '先着順のイベント'
    end
    accept_confirm do
      click_link '参加申込'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[kimura hatsuno], participants
    end
  end

  test 'display user to waitlist when event participants are full' do
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
    within 'ul.card-list' do
      click_link '補欠者のいるイベント'
    end
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
    within 'ul.card-list' do
      click_link '補欠者が繰り上がるイベント'
    end
    accept_confirm do
      click_link '補欠登録'
    end
    assert_text '参加登録しました'
    within '.participants' do
      participants = all('img').map { |img| img['alt'] }
      assert_equal %w[kimura], participants
    end

    visit_with_auth events_path, 'kimura'
    within 'ul.card-list' do
      click_link '補欠者が繰り上がるイベント'
    end
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

  test 'When signing up for an event during Watch, Watch is not registered twice' do
    visit_with_auth event_path(events(:event2)), 'komagata'
    find('.watch-toggle').click
    accept_confirm do
      click_link '参加申込'
    end

    assert_text '参加登録しています。'
    visit_with_auth '/current_user/watches', 'komagata'
    assert_selector '.card-list-item', count: 1
  end
end
