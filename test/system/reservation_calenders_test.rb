# frozen_string_literal: true

require 'application_system_test_case'

class ReservationCalendersTest < ApplicationSystemTestCase
  test 'show this month reservation calender' do
    visit_with_auth '/reservation_calenders', 'komagata'
    assert_equal '席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title
  end

  test 'show next month of 2019/10 reservation calender' do
    visit_with_auth '/reservation_calenders/201910', 'komagata'
    click_link 'next-month'
    assert_text '2019年11月'
  end
end
