# frozen_string_literal: true

require "application_system_test_case"

class ReservationsTest < ApplicationSystemTestCase
  def setup
    login_user "komagata", "testtest"
  end

  test "create reservation" do
    visit "/reservation_calenders/201911"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    within("#reservation-2019-11-02-#{seats(:seat_2).id}") do
      click_button
    end
    within("#reservation-2019-11-02-#{seats(:seat_2).id}") do
      assert_text "komagata"
    end
  end

  test "delete reservation" do
    visit "/reservation_calenders/201911"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    accept_confirm do
      within("#reservation-#{reservations(:reservation_1).date}-#{reservations(:reservation_1).seat.id}") do
        click_button
      end
    end
    within("#reservation-#{reservations(:reservation_1).date}-#{reservations(:reservation_1).seat.id}") do
      assert_no_text "komagata"
    end
  end

  test "reservations beyond one month cannot be made" do
    visit "/reservation_calenders"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    click_on "来月"

    reservation_date = Date.current.next_month.tomorrow

    if (Date.current.month + 2) <= reservation_date.month
      click_on "来月"
    end
    accept_confirm do
      within("#reservation-#{reservation_date}-#{seats(:seat_2).id}") do
        click_button
      end
    end

    within("#reservation-#{reservation_date}-#{seats(:seat_2).id}") do
      assert_no_text "komagata"
    end
  end
end
