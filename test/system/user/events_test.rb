# frozen_string_literal: true

require 'application_system_test_case'

class User::EventsTest < ApplicationSystemTestCase
  test 'shows the event listing for a user' do
    visit_with_auth "/users/#{users(:komagata).id}/events", 'komagata'
    assert_equal 'komagataのイベント一覧 | FBC', title
  end

  test 'shows only events the user is participating in' do
    visit_with_auth "/users/#{users(:kimura).id}/events", 'kimura'
    assert_text 'kimura専用イベント'
    assert_no_text '募集期間中のイベント(補欠者なし)'
  end
end
