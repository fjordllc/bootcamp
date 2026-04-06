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
    visit_with_auth "/users/#{users(:kimura).id}/events", 'kimura'
    assert_text 'kimura専用イベント'
    assert_no_text '募集期間中のイベント(補欠者なし)'
  end
end
