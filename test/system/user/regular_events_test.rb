# frozen_string_literal: true

require 'application_system_test_case'

class User::RegularEventsTest < ApplicationSystemTestCase
  test 'shows the regular event listing for a user ' do
    visit_with_auth "/users/#{users(:komagata).id}/regular_events", 'komagata'
    assert_equal 'komagataのイベント一覧 | FBC', title
    nav = find('a.tab-nav__item-link', text: /定期イベント\(\d+\)/)
    assert nav.matches_css?('.is-active')
  end

  test 'shows correct count of user participating regular events' do
    visit_with_auth "/users/#{users(:kimura).id}/regular_events", 'kimura'
    assert_text "定期イベント(#{users(:kimura).participate_regular_events.count})"
  end

  test 'does not show regular events the user is not participating in' do
    visit_with_auth "/users/#{users(:kimura).id}/regular_events", 'kimura'
    assert_text '独習Git輪読会'
    assert_no_text '開発MTG'
  end
end
