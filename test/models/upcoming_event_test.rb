# frozen_string_literal: true

require 'test_helper'

class UpcomingEventTest < ActiveSupport::TestCase
  setup do
    @special = events(:event1)
    @upcoming_special = UpcomingEvent.wrap(@special)

    @regular = regular_events(:regular_event1)
    @upcoming_regular = UpcomingEvent.wrap(@regular)
  end

  test '.wrap' do
    assert_equal UpcomingEvent.new(@special), UpcomingEvent.wrap(@special)
    assert_equal UpcomingEvent.new(@regular), UpcomingEvent.wrap(@regular)
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
      @special.update!(
        start_at: Time.zone.local(2023, 1, 1, 9, 0),
        end_at: Time.zone.local(2023, 1, 1, 11, 0)
      )
      upcoming_special = UpcomingEvent.wrap(@special)
      assert_equal Time.zone.local(2023, 1, 1, 9, 0, 0), upcoming_special.scheduled_date

      # 祝日開催・非開催関係なく、ただ予定されている日を返す
      upcoming_regular = UpcomingEvent.wrap(@regular)
      assert_equal Time.zone.local(2023, 1, 1, 15, 0, 0), upcoming_regular.scheduled_date
    end
  end

  test '#held?' do
    scheduled_date = Time.zone.local(2023, 1, 1) # 祝日

    assert @upcoming_special.held?(scheduled_date)

    @regular.update!(hold_national_holiday: true)
    upcoming_regular = UpcomingEvent.wrap(@regular)
    assert upcoming_regular.held?(scheduled_date)

    @regular.update!(hold_national_holiday: false)
    upcoming_regular = UpcomingEvent.wrap(@regular)
    assert_not upcoming_regular.held?(scheduled_date)
  end

  test '#for_job_hunting?' do
    @special.update!(job_hunting: true)
    upcoming_special = UpcomingEvent.wrap(@special)
    assert upcoming_special.for_job_hunting?

    @special.update!(job_hunting: false)
    upcoming_special = UpcomingEvent.wrap(@special)
    assert_not upcoming_special.for_job_hunting?
  end

  test '#participants' do
    assert_equal @special.participants, @upcoming_special.participants
    assert_equal @regular.participants, @upcoming_regular.participants
  end
end
