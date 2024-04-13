# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @special = events(:event1)
    @special.update!(
      start_at: Time.zone.local(2023, 1, 1, 9, 0),
      end_at: Time.zone.local(2023, 1, 1, 11, 0)
    )
    @upcoming_special = UpcomingEvent.wrap(@special)
    @upcoming_special_not_for_job_hunting = @upcoming_special

    special_for_job_hunting = events(:event29)
    @upcoming_special_for_job_junting = UpcomingEvent.wrap(special_for_job_hunting)

    @regular = regular_events(:regular_event1)
    @upcoming_regular = UpcomingEvent.wrap(@regular)
    @upcoming_regular_not_held_national_holiday = @upcoming_regular

    regular_held_national_holiday = regular_events(:regular_event5)
    @upcoming_regular_held_national_holiday = UpcomingEvent.wrap(regular_held_national_holiday)
  end

  test '#original_event' do
    assert_equal @special, @upcoming_special.original_event
    assert_equal @regular, @upcoming_regular.original_event
  end

  test '#title' do
    assert_equal 'ミートアップ', @upcoming_special.title
    assert_equal '開発MTG', @upcoming_regular.title
  end

  test '#scheduled_date' do
    travel_to Time.zone.local(2023, 1, 1, 0, 0, 0) do
      assert_equal Time.zone.local(2023, 1, 1, 9, 0, 0), @upcoming_special.scheduled_date

      # RegularEventにおけるscheduled_dateは、内部でTime.nowを呼んでいる
      # 日付関係がおかしくならないよう、travel_to内でインスタンス化
      regular = regular_events(:regular_event32)
      upcoming_regular = UpcomingEvent.wrap(regular)
      assert_equal Time.zone.local(2023, 1, 2, 21, 0, 0), upcoming_regular.scheduled_date
    end
  end

  test '#held?' do
    scheduled_date = Time.zone.local(2023, 1, 1)
    assert @upcoming_special.held?(scheduled_date)
    assert @upcoming_regular_held_national_holiday.held?(scheduled_date)
    assert_not @upcoming_regular_not_held_national_holiday.held?(scheduled_date)
  end

  test '#for_job_hunting?' do
    assert @upcoming_special_for_job_junting.for_job_hunting?
    assert_not @upcoming_special_not_for_job_hunting.for_job_hunting?
  end

  test '#participants' do
    assert_equal @special.participants, @upcoming_special.participants
    assert_equal @regular.participants, @upcoming_regular.participants
  end
end
