# frozen_string_literal: true

require "application_system_test_case"

class ReservationsTest < ApplicationSystemTestCase
  setup do
    login_user "hatsuno", "testtest"
  end

  test "create reservation" do
    visit "/reservation_calenders/201911"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    within("#reservation-2019-11-02-#{seats(:seat_2).id}") do
      find("#reserve-seat").click
    end
    within("#reservation-2019-11-02-#{seats(:seat_2).id}") do
      assert_text "hatsuno"
    end
  end

  test "delete reservation" do
    visit "/reservation_calenders/201911"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title

    accept_confirm do
      within("#reservation-#{reservations(:reservation_4).date}-#{reservations(:reservation_4).seat.id}") do
        find("#cancel-reservation").click
      end
    end
    within("#reservation-#{reservations(:reservation_4).date}-#{reservations(:reservation_4).seat.id}") do
      assert_no_text "hatsuno"
    end
  end

  test "reservations beyond one month cannot be made" do
    visit "/reservation_calenders"
    assert_equal "席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）", title
    click_link "next-month"

    reservation_date = Date.current.next_month.tomorrow

    if (Date.current.month + 2) <= reservation_date.month
      click_link "next-month"
    end
    accept_confirm do
      within("#reservation-#{reservation_date}-#{seats(:seat_2).id}") do
        find("#reserve-seat").click
      end
    end

    within("#reservation-#{reservation_date}-#{seats(:seat_2).id}") do
      assert_no_text "hatsuno"
    end
  end
end
