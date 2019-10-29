# frozen_string_literal: true

require "application_system_test_case"

class ReservationsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "create reservation" do
    visit "/reservation_calenders/201910"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    within("#reservation-2019-10-02-#{seats(:seat_2).id}") do
      click_button
    end
    assert_text "予約しました"
  end

  test "delete reservation" do
    visit "/reservation_calenders/201910"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    accept_confirm do
      click_on "komagata", match: :first
    end

    assert_text "予約を解約しました"
  end

  test "reservations beyond one month cannot be made" do
    visit "/reservation_calenders"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    click_on "来月"

    if Date.today == Date.today.end_of_month
      click_on "来月"
    end

    within("#reservation-#{Date.tomorrow.next_month}-#{seats(:seat_2).id}") do
      click_button
    end
    assert_text "日付は一ヶ月先までしか予約できません"
  end
end
