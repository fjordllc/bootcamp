# frozen_string_literal: true

require "application_system_test_case"

class ReservationCalendersTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "show this month reservation calender" do
    visit "/reservation_calenders"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
  end

  test "show next month of 2019/10 reservation calender" do
    visit "/reservation_calenders/201910"
    click_on "来月"
    assert_text "2019年11月"
  end
end
