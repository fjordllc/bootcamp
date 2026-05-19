# frozen_string_literal: true

require 'application_system_test_case'

class User::EventsTest < ApplicationSystemTestCase
  test 'shows the event listing for a user' do
    visit_with_auth "/users/#{users(:komagata).id}/events", 'komagata'
    assert_equal 'komagataのイベント一覧 | FBC', title
    nav = find('a.tab-nav__item-link', text: /特別イベント\(\d+\)/)
    assert nav.matches_css?('.is-active')
  end

  test 'shows correct count of user participating events' do
    visit_with_auth "/users/#{users(:kimura).id}/events", 'kimura'
    assert_selector '.tab-nav__item-link', text: "特別イベント(#{users(:kimura).participate_events.count})"
  end

  test 'does not show events the user is not participating in' do
    participated_event = events(:event30)
    non_participated_event = events(:event34)
    start_at = 1.month.from_now

    participated_event.update!(
      start_at:,
      end_at: start_at + 2.hours,
      open_start_at: start_at - 1.month,
      open_end_at: start_at - 1.hour
    )
    non_participated_event.update!(
      user: users(:komagata),
      start_at:,
      end_at: start_at + 2.hours,
      open_start_at: start_at - 1.month,
      open_end_at: start_at - 1.hour
    )

    visit_with_auth "/users/#{users(:kimura).id}/events", 'kimura'
    assert_text '未来のイベント(参加済)'
    assert_no_text '未来のイベント(未参加)'
  end
end
