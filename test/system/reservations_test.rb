# frozen_string_literal: true

require 'application_system_test_case'

class ReservationsTest < ApplicationSystemTestCase
  test 'create reservation' do
    visit_with_auth '/reservation_calenders/201911', 'hatsuno'
    assert_equal '席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    within("#reservation-2019-11-02-#{seats(:seat2).id}") do
      find('#reserve-seat').click
    end
    within("#reservation-2019-11-02-#{seats(:seat2).id}") do
      assert_text 'hatsuno'
    end
  end

  test 'delete reservation' do
    visit_with_auth '/reservation_calenders/201911', 'hatsuno'
    assert_equal '席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

    accept_confirm do
      within("#reservation-#{reservations(:reservation4).date}-#{reservations(:reservation4).seat.id}") do
        find('#cancel-reservation').click
      end
    end
    within("#reservation-#{reservations(:reservation4).date}-#{reservations(:reservation4).seat.id}") do
      assert_no_text 'hatsuno'
    end
  end

  test 'reservations beyond one month cannot be made' do
    travel_to Time.zone.local(2020, 1, 1, 0, 0, 0) do
      reservation_date = Date.current.next_month.tomorrow
      visit_with_auth "/reservation_calenders/#{reservation_date.strftime('%Y%m')}/", 'hatsuno'
      assert_equal '席予約一覧 | FJORD BOOT CAMP（フィヨルドブートキャンプ）', title

      accept_confirm do
        within("#reservation-#{reservation_date}-#{seats(:seat2).id}") do
          find('#reserve-seat').click
        end
      end

      within("#reservation-#{reservation_date}-#{seats(:seat2).id}") do
        assert_no_text 'hatsuno'
      end
    end
  end
end
